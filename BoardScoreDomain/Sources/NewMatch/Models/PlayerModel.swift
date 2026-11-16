//
//  PlayerModel.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation

public extension Domain {
    struct PlayerModel: Sendable, Hashable, Identifiable {
        public let id: UUID
        public let name: String

        public init(id: UUID = UUID(), name: String) {
            self.id = id
            self.name = name
        }
    }
}
