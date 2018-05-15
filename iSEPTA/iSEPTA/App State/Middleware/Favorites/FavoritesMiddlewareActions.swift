//
//  FavoritesMiddlewareActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
protocol FavoritesMiddlewareAction: SeptaAction {}

struct SaveFavorite: FavoritesMiddlewareAction {
    let favorite: Favorite
    let description = "User adds a Favorite"
}

struct RemoveFavorite: FavoritesMiddlewareAction {
    let favorite: Favorite
    let description = "User removes a favorite"
}
