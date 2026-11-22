//
//  AsyncTestHelpers.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 14/11/2026.
//

import Foundation
import Testing

func until(condition: @escaping () -> Bool,
           timeout: Double = 5,
           isolation _: isolated (any Actor?) = #isolation,
           _ file: String = #file,
           _ line: Int = #line,
           _ sourceLocation: SourceLocation = #_sourceLocation
) async throws {
    enum TestError: Error {
        case timedOut
    }

    let date = Date().advanced(by: timeout)
    while !condition() {
        if Date() > date {
            Issue.record(TestError.timedOut, sourceLocation: sourceLocation)
            throw TestError.timedOut
        }
        await Task.yield()
    }
}
