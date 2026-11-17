//
//  NewPlayerModel.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 17/11/2026.
//

public extension Domain {
    struct NewPlayerModel: Sendable, Equatable {
        public let name: String

        public init(name: String) {
            self.name = name
        }
    }
}
