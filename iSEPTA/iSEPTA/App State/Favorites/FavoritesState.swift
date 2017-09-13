//
//  FavoriteState.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

struct FavoritesState: Codable {
    let favorites: [Favorite]
    let nextToArriveUpdateStatus: NextToArriveUpdateStatus
    let refreshDataRequested: Bool

    init(favorites: [Favorite] = [Favorite](), nextToArriveUpdateStatus: NextToArriveUpdateStatus = .idle, refreshDataRequested: Bool = false) {
        self.favorites = favorites
        self.nextToArriveUpdateStatus = nextToArriveUpdateStatus
        self.refreshDataRequested = refreshDataRequested
    }

    enum CodingKeys: String, CodingKey {
        case favorites
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self) // defining our (keyed) container

        favorites = try container.decode([Favorite].self, forKey: .favorites)
        nextToArriveUpdateStatus = .idle
        refreshDataRequested = false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(favorites, forKey: .favorites)
    }
}

extension FavoritesState: Equatable {}
func ==(lhs: FavoritesState, rhs: FavoritesState) -> Bool {
    var areEqual = true

    areEqual = lhs.favorites == rhs.favorites
    guard areEqual else { return false }

    areEqual = lhs.nextToArriveUpdateStatus == rhs.nextToArriveUpdateStatus
    guard areEqual else { return false }

    areEqual = lhs.refreshDataRequested == rhs.refreshDataRequested
    guard areEqual else { return false }

    return areEqual
}
