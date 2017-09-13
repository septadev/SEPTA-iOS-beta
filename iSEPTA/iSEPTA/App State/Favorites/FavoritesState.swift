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

    init(favorites: [Favorite] = [Favorite]()) {
        self.favorites = favorites
    }

    enum CodingKeys: String, CodingKey {
        case favorites
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self) // defining our (keyed) container

        favorites = try container.decode([Favorite].self, forKey: .favorites)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(favorites, forKey: .favorites)
    }
}

extension FavoritesState: Equatable {}
func ==(lhs: FavoritesState, rhs: FavoritesState) -> Bool {

    return lhs.favorites == rhs.favorites
}
