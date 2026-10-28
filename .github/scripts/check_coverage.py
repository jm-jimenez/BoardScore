#!/usr/bin/env python3
"""Checks failed tests and minimum coverage on the lines added in a PR."""
import argparse
import fnmatch
import json
import os
import re
import subprocess
import sys


def run(cmd):
    return subprocess.run(cmd, capture_output=True, text=True)


def matches(path, patterns):
    """True if the path (or just its file name) matches any wildcard pattern."""
    base = os.path.basename(path)
    return any(fnmatch.fnmatch(path, p) or fnmatch.fnmatch(base, p) for p in patterns)


def threshold_for(path, config):
    """Threshold of the first matching rule, or the default one."""
    for rule in config.get("rules", []):
        if matches(path, [rule["pattern"]]):
            return rule["threshold"]
    return config.get("default_threshold", 80)


def changed_lines(base):
    """{file: {added line numbers}} between origin/<base> and HEAD."""
    out = run(["git", "diff", "-U0", "--diff-filter=AM",
               f"origin/{base}...HEAD", "--", "*.swift"]).stdout
    files, current = {}, None
    for line in out.splitlines():
        if line.startswith("+++ b/"):
            current = line[6:]
            files[current] = set()
        elif line.startswith("@@") and current:
            m = re.search(r"\+(\d+)(?:,(\d+))?", line)
            start, count = int(m.group(1)), int(m.group(2) or 1)
            files[current].update(range(start, start + count))
    return files


LINE_RE = re.compile(r"^\s*(\d+):\s+(\*|\d+)")


def line_coverage(xcresult, abs_path):
    """{line: execution count} for executable lines only. None if there is no data."""
    r = run(["xcrun", "xccov", "view", "--archive", "--file", abs_path, xcresult])
    if r.returncode != 0 or not r.stdout.strip():
        return None
    cov = {}
    for line in r.stdout.splitlines():
        m = LINE_RE.match(line)
        if m and m.group(2) != "*":  # "*" means non-executable line
            cov[int(m.group(1))] = int(m.group(2))
    return cov


def failed_tests(xcresult):
    """List of (name, [messages]) for failed tests. None if results can't be read."""
    if not os.path.exists(xcresult):
        return None
    r = run(["xcrun", "xcresulttool", "get", "test-results", "tests", "--path", xcresult])
    if r.returncode != 0:
        return None
    failed = []

    def walk(node, trail):
        name = node.get("name", "")
        children = node.get("children", [])
        if node.get("nodeType") == "Test Case":
            if node.get("result") == "Failed":
                msgs = [c.get("name", "") for c in children
                        if c.get("nodeType") == "Failure Message"]
                failed.append((" / ".join(trail + [name]), msgs))
            return
        for child in children:
            walk(child, trail + [name])

    for root in json.loads(r.stdout).get("testNodes", []):
        walk(root, [])
    return failed


def to_ranges(lines):
    """Groups consecutive line numbers into (start, end) ranges."""
    ranges, start, prev = [], None, None
    for n in sorted(lines):
        if start is None:
            start = prev = n
        elif n == prev + 1:
            prev = n
        else:
            ranges.append((start, prev))
            start = prev = n
    if start is not None:
        ranges.append((start, prev))
    return ranges


def fmt(r):
    return f"{r[0]}" if r[0] == r[1] else f"{r[0]}-{r[1]}"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--xcresult", required=True)
    ap.add_argument("--config", required=True)
    args = ap.parse_args()

    with open(args.config) as f:
        config = json.load(f)
    base = os.environ.get("BASE_REF") or config.get("base_branch", "develop")
    root = run(["git", "rev-parse", "--show-toplevel"]).stdout.strip()

    ok = True

    # --- 1. Failed tests ---
    print("\n=== Failed tests ===")
    failed = failed_tests(args.xcresult)
    if failed is None:
        print("Could not read the test results (did the build fail?).")
        ok = False
    elif failed:
        ok = False
        for name, msgs in failed:
            print(f"  ✘ {name}")
            for m in msgs:
                print(f"      {m}")
            print(f"::error::Failed test: {name}")
    else:
        print("  All tests passed.")

    # --- 2. Coverage of the lines added in the PR ---
    print(f"\n=== Coverage of changes against {base} ===")
    below, passed, no_data = [], [], []
    for path, added in sorted(changed_lines(base).items()):
        if matches(path, config.get("exclude", [])):
            continue
        cov = line_coverage(args.xcresult, os.path.join(root, path))
        if cov is None:
            no_data.append(path)
            continue
        executable = [n for n in added if n in cov]
        if not executable:
            continue  # nothing measurable in the added lines
        uncovered = [n for n in executable if cov[n] == 0]
        covered_count = len(executable) - len(uncovered)
        pct = 100 * covered_count / len(executable)
        needed = threshold_for(path, config)
        if pct < needed:
            below.append((path, pct, needed, to_ranges(uncovered)))
        else:
            passed.append((path, pct, needed, covered_count, len(executable)))

    for path in no_data:
        print(f"  · {path}: no coverage data (skipped)")

    if below:
        ok = False
        print(f"\nBelow threshold ({len(below)}):")
        for path, pct, needed, ranges in below:
            blocks = ", ".join(fmt(r) for r in ranges)
            print(f"  ✘ {path}: {pct:.1f}% < {needed}%  (uncovered lines: {blocks})")
            print(f"::error file={path},line={ranges[0][0]}::"
                  f"Coverage {pct:.1f}% is below the required {needed}%")

    if passed:
        print(f"\nMeeting threshold ({len(passed)}):")
        for path, pct, needed, covered_count, total in passed:
            print(f"  ✔ {path}: {pct:.1f}% (min {needed}%, {covered_count}/{total} lines)")
    elif not below:
        print("  No files with measurable changes.")

    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
