//
//  FavoritesActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

protocol FavoritesAction: SeptaAction {}

struct LoadFavorites: FavoritesAction {
    let favorites: [Favorite]
    let description = "Loading favorites from file storage"
}

struct AddFavorite: FavoritesAction {
    let favorite: Favorite
    let description = "User adds a Favorite"
}

struct RemoveFavorite: FavoritesAction {
    let favorite: Favorite
    let description = "User removes a favorite"
}

struct UpdateFavorite: FavoritesAction {
    let favorite: Favorite
    let description: String
}
