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
}

extension FavoritesState: Equatable {}
func ==(lhs: FavoritesState, rhs: FavoritesState) -> Bool {
    var areEqual = true

    areEqual = lhs.favorites == rhs.favorites
    guard areEqual else { return false }

    return areEqual
}
