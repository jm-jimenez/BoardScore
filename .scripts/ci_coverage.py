#!/usr/bin/env python3
"""
CI para runner self-hosted de GitHub (macOS):

  1. Ejecuta los tests de Xcode (xcodebuild test) generando un .xcresult.
  2. Reporta los tests que fallan.
  3. Mide la cobertura SOLO sobre las líneas añadidas respecto a la rama base
     y exige un mínimo configurable.
  4. Informa de ficheros y bloques de líneas nuevas sin cubrir.
  5. Permite excluir ficheros por nombre o wildcard (p. ej. *View.swift).

Solo usa la librería estándar (sirve el python3 de las Command Line Tools).

Códigos de salida:
  0  todo correcto
  1  tests fallidos / no se pudieron ejecutar (tiene prioridad)
  2  tests correctos pero cobertura de los cambios por debajo del mínimo
  3  error de configuración / herramientas

Todo se puede pasar por argumentos o variables de entorno (ver --help).
Las rutas (workspace, bundle...) son relativas a la raíz del repositorio.
"""
from __future__ import annotations

import argparse
import fnmatch
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
from pathlib import Path

HUNK_RE = re.compile(r"^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@")
COV_LINE_RE = re.compile(r"^\s*(\d+):\s*(\*|\d+)")
FAIL_LOC_RE = re.compile(r"^(.+?\.swift):(\d+)(?::\d+)?:?\s*(.*)$", re.S)
SUITE_TYPES = {"Unit test bundle", "UI test bundle", "Test Suite"}

XCT_FAIL_RE = re.compile(r"Test Case '-?\[?([^']+?)\]?' failed")
ST_FAIL_RE = re.compile(r"✘ Test (.+?) failed")
LOG_ERR_RE = re.compile(r"^(.+?\.swift):(\d+)(?::\d+)?: error: (?:-\[(.+?)\] : )?(.*)")


# ----------------------------------------------------------------- utilidades
def split_list(value: str) -> list[str]:
    return [p.strip() for p in re.split(r"[,\n]", value or "") if p.strip()]


def run(cmd: list[str]) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, text=True, capture_output=True, errors="replace")


def git(*args: str, check: bool = True) -> str:
    r = run(["git", "-c", "core.quotepath=false", *args])
    if check and r.returncode != 0:
        die(f"git {' '.join(args)} falló: {r.stderr.strip()}", 3)
    return r.stdout


def die(msg: str, code: int) -> None:
    print(f"::error::{gh_escape(msg)}" if in_github() else f"ERROR: {msg}")
    sys.exit(code)


def in_github() -> bool:
    return bool(os.environ.get("GITHUB_ACTIONS"))


def gh_escape(s: str) -> str:
    return s.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")


def gh_prop(s: str) -> str:
    return gh_escape(s).replace(":", "%3A").replace(",", "%2C")


def annotate(level: str, msg: str, file: str | None = None,
             line: int | None = None, end: int | None = None, title: str | None = None) -> None:
    if not in_github():
        return
    props = []
    if file:
        props.append(f"file={gh_prop(file)}")
    if line:
        props.append(f"line={line}")
    if end:
        props.append(f"endLine={end}")
    if title:
        props.append(f"title={gh_prop(title)}")
    print(f"::{level} {','.join(props)}::{gh_escape(msg)}")


def to_rel(path: str, root: Path) -> str:
    try:
        return Path(path).resolve().relative_to(root).as_posix()
    except (ValueError, OSError):
        return path


# ----------------------------------------------------------------- exclusiones
def load_excludes(a: argparse.Namespace) -> list[str]:
    pats = list(a.exclude) + split_list(os.environ.get("COVERAGE_EXCLUDE", ""))
    f = Path(a.exclude_file)
    if f.is_file():
        for line in f.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line and not line.startswith("#"):
                pats.append(line)
    return pats


def is_excluded(rel: str, pats: list[str]) -> bool:
    """Patrón sin '/' -> se compara con el nombre del fichero (*View.swift).
    Patrón con '/' -> se compara con la ruta relativa al repo (fnmatch, '*' cruza '/').
    Patrón acabado en '/' -> excluye cualquier directorio con ese nombre (Generated/)."""
    name = os.path.basename(rel)
    for p in pats:
        if p.endswith("/"):
            if "/" + p.strip("/") + "/" in "/" + rel:
                return True
        elif "/" in p:
            if fnmatch.fnmatchcase(rel, p) or fnmatch.fnmatchcase(rel, p.lstrip("/")):
                return True
        elif fnmatch.fnmatchcase(name, p):
            return True
    return False


def is_test_file(rel: str) -> bool:
    parts = rel.split("/")
    return rel.endswith("Tests.swift") or any(p.endswith("Tests") for p in parts[:-1])


# ------------------------------------------------------------------------ git
def verify(ref: str) -> bool:
    return run(["git", "rev-parse", "--verify", "--quiet", f"{ref}^{{commit}}"]).returncode == 0


def resolve_base(arg: str | None) -> str:
    gh = os.environ.get("GITHUB_BASE_REF")
    cands = [c for c in [arg, f"origin/{gh}" if gh else None, gh] if c]
    for c in cands:
        if verify(c):
            return c
    if gh:  # el checkout no trajo la rama base: la pedimos
        run(["git", "fetch", "--no-tags", "origin", gh])
        if verify(f"origin/{gh}"):
            return f"origin/{gh}"
    die("No se pudo determinar la rama base. Usa --base origin/main "
        "(o COVERAGE_BASE) y checkout con fetch-depth: 0.", 3)
    raise AssertionError  # inalcanzable


def changed_lines(base: str) -> dict[str, set[int]]:
    spec = ["--unified=0", "--no-color", "--diff-filter=AMR", "--", "*.swift"]
    r = run(["git", "-c", "core.quotepath=false", "diff", f"{base}...HEAD", *spec])
    if r.returncode != 0:
        print(f"AVISO: no hay merge-base con {base} (¿checkout superficial?); "
              "comparo contra la punta de la rama base. Usa fetch-depth: 0.")
        r = run(["git", "-c", "core.quotepath=false", "diff", base, "HEAD", *spec])
        if r.returncode != 0:
            die(f"git diff falló: {r.stderr.strip()}", 3)
    files: dict[str, set[int]] = {}
    cur = None
    for line in r.stdout.splitlines():
        if line.startswith("+++ "):
            p = line[4:].split("\t")[0]
            cur = p[2:] if p.startswith("b/") else None
            if cur:
                files.setdefault(cur, set())
        elif cur:
            m = HUNK_RE.match(line)
            if m:
                start = int(m.group(1))
                count = int(m.group(2)) if m.group(2) is not None else 1
                files[cur].update(range(start, start + count))
    return {f: ls for f, ls in files.items() if ls}


# ---------------------------------------------------------------------- tests
def run_tests(a: argparse.Namespace, bundle: str) -> tuple[int, list[str]]:
    if Path(bundle).exists():
        shutil.rmtree(bundle)
    Path(bundle).parent.mkdir(parents=True, exist_ok=True)
    cmd = ["xcodebuild", "test"]
    cmd += ["-workspace", a.workspace] if a.workspace else ["-project", a.project]
    cmd += ["-scheme", a.scheme, "-destination", a.destination,
            "-resultBundlePath", bundle, "-enableCodeCoverage", "YES", *a.xcodebuild_args]
    print("::group::xcodebuild test" if in_github() else "--- xcodebuild test ---")
    print("$ " + " ".join(shlex.quote(c) for c in cmd), flush=True)
    log: list[str] = []
    with subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                          text=True, errors="replace") as proc:
        assert proc.stdout is not None
        for line in proc.stdout:
            sys.stdout.write(line)
            log.append(line)
    print("::endgroup::" if in_github() else "--- fin xcodebuild ---", flush=True)
    return proc.returncode, log


def _failure_messages(node: dict) -> list[str]:
    msgs = [node.get("name", "")] if node.get("nodeType") == "Failure Message" else []
    for c in node.get("children") or []:
        msgs += _failure_messages(c)
    return msgs


def _walk(node: dict, trail: list[str], out: dict[str, dict]) -> None:
    t, name = node.get("nodeType"), node.get("name", "")
    if t == "Test Case":
        if node.get("result") == "Failed":
            full = "/".join(trail + [name])
            entry = out.setdefault(full, {"name": full, "messages": []})
            for m in _failure_messages(node):
                if m and m not in entry["messages"]:
                    entry["messages"].append(m)
        return
    nxt = trail + [name] if t in SUITE_TYPES else trail
    for c in node.get("children") or []:
        _walk(c, nxt, out)


def failed_tests_from_log(log: list[str]) -> list[dict]:
    out: dict[str, dict] = {}
    errors = [LOG_ERR_RE.match(l.strip()) for l in log]
    for l in log:
        m = XCT_FAIL_RE.search(l) or ST_FAIL_RE.search(l)
        if m:
            name = m.group(1).replace(" ", "/", 1) if "[" not in m.group(1) else m.group(1)
            out.setdefault(name, {"name": name, "messages": []})
    for e in errors:
        if e and e.group(3):
            key = e.group(3).replace(" ", "/", 1)
            if key in out:
                out[key]["messages"].append(f"{e.group(1)}:{e.group(2)}: {e.group(4)}")
    return list(out.values())


def get_failed_tests(bundle: str, log: list[str]) -> list[dict]:
    r = run(["xcrun", "xcresulttool", "get", "test-results", "tests", "--path", bundle])
    if r.returncode == 0:
        try:
            out: dict[str, dict] = {}
            for n in json.loads(r.stdout).get("testNodes", []):
                _walk(n, [], out)
            return list(out.values())
        except ValueError:
            pass
    print("AVISO: no pude leer los tests con xcresulttool; interpreto el log de xcodebuild.")
    return failed_tests_from_log(log)


def get_test_counts(bundle: str) -> dict:
    r = run(["xcrun", "xcresulttool", "get", "test-results", "summary", "--path", bundle])
    try:
        d = json.loads(r.stdout)
        return {k: d.get(k) for k in ("totalTestCount", "passedTests", "failedTests", "skippedTests")}
    except ValueError:
        return {}


# ------------------------------------------------------------------ cobertura
def coverage_files(bundle: str, root: Path, skip_targets: list[str]) -> dict[str, str]:
    """rel -> ruta absoluta, solo de targets que NO son de test."""
    r = run(["xcrun", "xccov", "view", "--report", "--json", bundle])
    if r.returncode != 0:
        die(f"xccov no pudo leer el informe de cobertura: {r.stderr.strip()}", 3)
    files: dict[str, str] = {}
    for t in json.loads(r.stdout).get("targets", []):
        if any(fnmatch.fnmatchcase(t.get("name", ""), p) for p in skip_targets):
            continue
        for f in t.get("files", []):
            files[to_rel(f["path"], root)] = f["path"]
    return files


def line_coverage(bundle: str, abspath: str) -> dict[int, int] | None:
    for extra in ([], ["--archive"]):
        r = run(["xcrun", "xccov", "view", *extra, "--file", abspath, bundle])
        if r.returncode == 0:
            cov: dict[int, int] = {}
            for line in r.stdout.splitlines():
                m = COV_LINE_RE.match(line)
                if m and m.group(2) != "*":  # '*' = línea no ejecutable
                    n, c = int(m.group(1)), int(m.group(2))
                    cov[n] = max(cov.get(n, 0), c)
            return cov
    return None


def uncovered_blocks(exec_added: list[int], cov: dict[int, int]) -> list[tuple[int, int]]:
    """Agrupa líneas nuevas sin cubrir en bloques contiguos: se corta el bloque si entre
    dos líneas hay código ejecutable cubierto o más de 10 líneas de distancia."""
    blocks: list[tuple[int, int]] = []
    start = prev = None
    for l in exec_added:
        if cov[l] > 0:
            if start is not None:
                blocks.append((start, prev))
                start = None
            continue
        if start is not None and (l - prev > 10 or any(cov.get(k, 0) > 0 for k in range(prev + 1, l))):
            blocks.append((start, prev))
            start = None
        if start is None:
            start = l
        prev = l
    if start is not None:
        blocks.append((start, prev))
    return blocks


def snippet(rel: str, a: int, b: int, limit: int = 8) -> list[str]:
    try:
        lines = Path(rel).read_text(encoding="utf-8", errors="replace").splitlines()
    except OSError:
        return []
    chunk = [f"{n:>5} | {lines[n - 1]}" for n in range(a, min(b, a + limit - 1) + 1) if n <= len(lines)]
    if b - a + 1 > limit:
        chunk.append(f"      | … ({b - a + 1 - limit} líneas más)")
    return chunk


def measure(a: argparse.Namespace, bundle: str, root: Path, base: str,
            excludes: list[str]) -> dict:
    changed = changed_lines(base)
    report_files = coverage_files(bundle, root, a.exclude_target)
    res = {"base": base, "min": a.min_coverage, "files": [], "excluded": [],
           "no_data": [], "covered": 0, "executable": 0, "pct": 100.0}
    for rel, added in sorted(changed.items()):
        if is_excluded(rel, excludes):
            res["excluded"].append(rel)
            continue
        if rel not in report_files:
            if not is_test_file(rel):
                res["no_data"].append(rel)
            continue
        cov = line_coverage(bundle, report_files[rel])
        if cov is None:
            res["no_data"].append(rel)
            continue
        exec_added = sorted(l for l in added if l in cov)
        if not exec_added:
            continue
        covered = sum(1 for l in exec_added if cov[l] > 0)
        blocks = uncovered_blocks(exec_added, cov)
        res["files"].append({"path": rel, "covered": covered, "executable": len(exec_added),
                             "pct": 100.0 * covered / len(exec_added), "blocks": blocks})
        res["covered"] += covered
        res["executable"] += len(exec_added)
    if res["executable"]:
        res["pct"] = 100.0 * res["covered"] / res["executable"]
    res["below"] = [f for f in res["files"] if f["pct"] < a.min_coverage]
    res["per_file"] = a.per_file
    res["ok"] = (res["executable"] == 0 or res["pct"] >= a.min_coverage) \
        and not (a.per_file and res["below"])
    return res


# -------------------------------------------------------------------- informe
def split_failure(msg: str) -> tuple[str | None, int | None, str]:
    m = FAIL_LOC_RE.match(msg)
    return (m.group(1), int(m.group(2)), m.group(3).strip()) if m else (None, None, msg)


def print_console(tests: dict, cov: dict | None, root: Path) -> None:
    bar = "=" * 70
    print("\n" + bar)
    # ---- Lista 1: tests fallidos
    if tests["failed"]:
        print(f"✘ TESTS FALLIDOS ({len(tests['failed'])})")
        for t in tests["failed"]:
            print(f"  - {t['name']}")
            for m in t["messages"]:
                print(f"      {m}")
    elif tests.get("error"):
        print(f"✘ {tests['error']}")
    else:
        c = tests.get("counts") or {}
        extra = f" ({c['passedTests']}/{c['totalTestCount']})" if c.get("totalTestCount") else ""
        print(f"✔ TESTS CORRECTOS{extra}")
    if cov is None:
        return
    # ---- Lista 2: ficheros con cambios por debajo del mínimo
    print(bar)
    if cov["executable"]:
        print(f"Cobertura total de líneas nuevas vs {cov['base']}: {cov['pct']:.1f}% "
              f"({cov['covered']}/{cov['executable']}) — mínimo {cov['min']:.1f}%")
    else:
        print(f"Sin líneas ejecutables nuevas que medir vs {cov['base']}")
    below = cov["below"]
    if below:
        print(f"✘ FICHEROS POR DEBAJO DEL MÍNIMO {cov['min']:.1f}% ({len(below)})")
        for f in below:
            print(f"  - {f['path']}: {f['pct']:.1f}% ({f['covered']}/{f['executable']})")
            for a, b in f["blocks"]:
                print(f"      sin cubrir: líneas {a}-{b}" if a != b else f"      sin cubrir: línea {a}")
                for s in snippet(f["path"], a, b):
                    print(f"        {s}")
    else:
        print(f"✔ NINGÚN FICHERO POR DEBAJO DEL MÍNIMO {cov['min']:.1f}%")
    if cov["excluded"]:
        print(f"  (excluidos por reglas: {len(cov['excluded'])})")
    if cov["no_data"]:
        print(f"  ⚠ Sin datos de cobertura, no medidos ({len(cov['no_data'])}): "
              + ", ".join(cov["no_data"]))
    print(bar)


def write_summary(tests: dict, cov: dict | None) -> None:
    path = os.environ.get("GITHUB_STEP_SUMMARY")
    if not path:
        return
    md = ["## Tests"]
    if tests["failed"]:
        md.append(f"❌ **{len(tests['failed'])} tests fallidos**\n")
        for t in tests["failed"]:
            md.append(f"- `{t['name']}`")
            md += [f"  - `{m}`" for m in t["messages"]]
    elif tests.get("error"):
        md.append(f"❌ {tests['error']}")
    else:
        md.append("✅ Tests correctos")
    if cov is not None:
        md.append("\n## Ficheros con cambios por debajo del mínimo")
        head = (f"Cobertura total de líneas nuevas: **{cov['pct']:.1f}%** "
                f"({cov['covered']}/{cov['executable']}) — mínimo {cov['min']:.1f}% — base `{cov['base']}`"
                if cov["executable"] else f"Sin líneas ejecutables nuevas respecto a `{cov['base']}`.")
        md.append(head + "\n")
        if cov["below"]:
            md.append(f"❌ **{len(cov['below'])} ficheros por debajo del mínimo**\n")
            md.append("| Fichero | Cobertura | Líneas sin cubrir |\n|---|---|---|")
            for f in cov["below"]:
                blocks = ", ".join(f"{a}-{b}" if a != b else str(a) for a, b in f["blocks"]) or "—"
                md.append(f"| `{f['path']}` | {f['pct']:.1f}% ({f['covered']}/{f['executable']}) | {blocks} |")
        else:
            md.append("✅ Ningún fichero por debajo del mínimo")
        if cov["excluded"]:
            md.append("\n<details><summary>Excluidos por reglas</summary>\n\n"
                      + "\n".join(f"- `{p}`" for p in cov["excluded"]) + "\n</details>")
        if cov["no_data"]:
            md.append("\n⚠️ **Sin datos de cobertura (no medidos):**\n"
                      + "\n".join(f"- `{p}`" for p in cov["no_data"]))
    with open(path, "a", encoding="utf-8") as fh:
        fh.write("\n".join(md) + "\n")


def emit_annotations(tests: dict, cov: dict | None, root: Path) -> None:
    for t in tests["failed"]:
        f, line, msg = (None, None, "")
        if t["messages"]:
            f, line, msg = split_failure(t["messages"][0])
            if f:
                f = to_rel(f, root) if os.path.isabs(f) else f
        annotate("error", msg or "Test fallido", f, line, title=f"Test fallido: {t['name']}")
    if cov is None:
        return
    for f in cov["below"]:
        for a, b in f["blocks"]:
            annotate("warning", f"Líneas nuevas sin cubrir ({a}-{b})", f["path"], a, b, "Sin cobertura")
    if not cov["ok"]:
        why = (f"{len(cov['below'])} ficheros por debajo del mínimo {cov['min']:.1f}%"
               if cov.get("per_file") and cov["below"] and cov["pct"] >= cov["min"]
               else f"Cobertura de los cambios {cov['pct']:.1f}% < mínimo {cov['min']:.1f}%")
        annotate("error", why, title="Cobertura insuficiente")


# ----------------------------------------------------------------------- main
def parse_args() -> argparse.Namespace:
    e = os.environ.get
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--workspace", default=e("XCODE_WORKSPACE"), help="[XCODE_WORKSPACE]")
    p.add_argument("--project", default=e("XCODE_PROJECT"), help="[XCODE_PROJECT] (si no hay workspace)")
    p.add_argument("--scheme", default=e("XCODE_SCHEME"), help="[XCODE_SCHEME]")
    p.add_argument("--destination", default=e("XCODE_DESTINATION"),
                   help="[XCODE_DESTINATION] p. ej. 'platform=iOS Simulator,name=iPhone 16'")
    p.add_argument("--result-bundle", default=e("RESULT_BUNDLE", "build/TestResults.xcresult"),
                   help="[RESULT_BUNDLE] ruta del .xcresult (se borra antes de ejecutar)")
    p.add_argument("--base", default=e("COVERAGE_BASE"),
                   help="[COVERAGE_BASE] rama base; por defecto origin/$GITHUB_BASE_REF")
    p.add_argument("--min-coverage", type=float, default=float(e("MIN_COVERAGE", "80")),
                   help="[MIN_COVERAGE] %% mínimo de líneas nuevas cubiertas (defecto 80)")
    p.add_argument("--per-file", action="store_true", default=e("COVERAGE_PER_FILE") == "1",
                   help="[COVERAGE_PER_FILE=1] falla si CUALQUIER fichero cambiado queda por debajo "
                        "del mínimo (por defecto solo se exige el mínimo sobre el total)")
    p.add_argument("--exclude", action="append", default=[], metavar="PATRON",
                   help="fichero o wildcard a excluir (repetible): Foo.swift, *View.swift, "
                        "Sources/*/Generated/*, Mocks/. También [COVERAGE_EXCLUDE] separado por comas")
    p.add_argument("--exclude-file", default=e("COVERAGE_EXCLUDE_FILE", ".coverage-exclude"),
                   help="fichero con un patrón por línea (# comentarios); defecto .coverage-exclude")
    p.add_argument("--exclude-target", action="append", default=None, metavar="PATRON",
                   help="targets del informe a ignorar (defecto: *.xctest y *Tests)")
    p.add_argument("--skip-tests", action="store_true",
                   help="no ejecuta xcodebuild; analiza un --result-bundle ya existente")
    p.add_argument("xcodebuild_args", nargs="*", help="tras '--': argumentos extra para xcodebuild")
    a = p.parse_args()
    a.exclude_target = a.exclude_target or ["*.xctest", "*Tests"]
    if not a.skip_tests and not (a.scheme and a.destination and (a.workspace or a.project)):
        p.error("faltan --scheme, --destination y --workspace/--project")
    return a


def main() -> int:
    a = parse_args()
    root = Path(git("rev-parse", "--show-toplevel").strip()).resolve()
    os.chdir(root)
    bundle = a.result_bundle
    excludes = load_excludes(a)
    log: list[str] = []
    rc = 0

    if not a.skip_tests:
        rc, log = run_tests(a, bundle)

    tests: dict = {"failed": [], "counts": {}}
    if not Path(bundle).exists():
        errs = [l.strip() for l in log if " error: " in l][:20]
        tests["error"] = ("xcodebuild no generó resultados (¿error de compilación?)"
                          + ("\n    " + "\n    ".join(errs) if errs else ""))
        print_console(tests, None, root)
        write_summary(tests, None)
        annotate("error", tests["error"], title="Fallo de build/tests")
        return 1

    tests["failed"] = get_failed_tests(bundle, log)
    tests["counts"] = get_test_counts(bundle)
    if rc != 0 and not tests["failed"]:
        tests["error"] = (f"xcodebuild terminó con código {rc} sin tests fallidos identificables "
                          "(¿error de compilación o crash del runner de tests?)")
    tests_ok = not tests["failed"] and not tests.get("error")

    base = resolve_base(a.base)
    cov = measure(a, bundle, root, base, excludes)

    print_console(tests, cov, root)
    write_summary(tests, cov)
    emit_annotations(tests, cov, root)

    if not tests_ok:
        return 1
    return 0 if cov["ok"] else 2


if __name__ == "__main__":
    sys.exit(main())
