//
//  FavoritesActions.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest

protocol FavoritesAction: SeptaAction {}

struct LoadFavorites: FavoritesAction {
    let favorites: [Favorite]
    let description = "Loading favorites from file storage"
}

struct AddFavorite: FavoritesAction {
    let favorite: Favorite
    let description = "User adds a Favorite"
}

struct EditFavorite: FavoritesAction {
    let favorite: Favorite
    let description = "User wants to edit a favorite"
}

struct SaveEditedFavorite: FavoritesAction {
    let favorite: Favorite
    let description = "User adds a Favorite"
}

struct CancelFavoriteEdit: FavoritesAction {

    let description = "User cancels an edit Favorite action"
}

struct RemoveEditedFavorite: FavoritesAction {
    let favorite: Favorite
    let description = "User removes a favorite"
}

struct UpdateFavoriteNextToArriveTrips: FavoritesAction {
    let favoriteId: String
    let nextToArriveTrips: [NextToArriveTrip]
    let description = "Updating Favorite Next To Arrive Trips"
}

struct UpdateFavoriteNextToArriveUpdateStatus: FavoritesAction {
    let favoriteId: String
    let nextToArriveUpdateStatus: NextToArriveUpdateStatus
    let description = "Updating Favorite Next To Arrive Trips"
}

struct RequestFavoriteNextToArriveUpdate: FavoritesAction {
    let favorite: Favorite
    let description: String
}

struct UpdateNextToArriveDetailForFavorite: FavoritesAction {
    let favoriteId: String
    let tripId: Int
    let realTimeArrivalDetail: RealTimeArrivalDetail
    let description: String
}

struct CreateNextToArriveFavorite: FavoritesAction {
    let favorite: Favorite
    let description = "Move Favorite to Next to Arrive Favorite"
}
