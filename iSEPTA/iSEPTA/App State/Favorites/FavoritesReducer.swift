//
//  FavoritesReducer.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

struct FavoritesReducer {
    static func main(action: Action, state: FavoritesState?) -> FavoritesState {
        if let state = state {
            guard let action = action as? FavoritesAction else { return state }
            return reduceFavoritesAction(action: action, state: state)
        } else {
            return FavoritesState()
        }
    }

    static func reduceFavoritesAction(action: FavoritesAction, state: FavoritesState) -> FavoritesState {
        var favoritesState = state
        switch action {
        case let action as LoadFavorites:
            favoritesState = reduceLoadFavorites(action: action, state: state)
        case let action as AddFavorite:
            favoritesState = reduceAddFavorite(action: action, state: state)
        case let action as EditFavorite:
            favoritesState = reduceEditFavorite(action: action, state: state)
        case let action as SaveEditedFavorite:
            favoritesState = reduceSaveFavorite(action: action, state: state)
        case let action as CancelFavoriteEdit:
            favoritesState = reduceCancelFavoriteEdit(action: action, state: state)
        case let action as RemoveEditedFavorite:
            favoritesState = reduceRemoveFavorite(action: action, state: state)
        case let action as UpdateFavoriteNextToArriveTrips:
            favoritesState = reduceUpdateFavoriteNextToArriveTrips(action: action, state: state)
        case let action as UpdateFavoriteNextToArriveUpdateStatus:
            favoritesState = reduceUpdateFavoriteNextToArriveUpdateStatus(action: action, state: state)
        case let action as CreateNextToArriveFavorite:
            favoritesState = reduceCreateNextToArriveFavorite(action: action, state: state)
        case let action as RequestFavoriteNextToArriveUpdate:
            favoritesState = reduceRequestFavoriteNextToArriveUpdate(action: action, state: state)
        case let action as UpdateNextToArriveDetailForFavorite:
            favoritesState = reduceUpdateNextToArriveDetailForFavorite(action: action, state: state)
        case let action as UploadReversedFavorite:
            favoritesState = reduceUploadReversedFavorite(action: action, state: state)
        case let action as UndoReversedFavorite:
            favoritesState = reduceUndoReversedFavorite(action: action, state: state)
        default:
            break
        }

        return favoritesState
    }

    static func reduceLoadFavorites(action: LoadFavorites, state: FavoritesState) -> FavoritesState {
        var newState = state
        newState.favorites = action.favorites
        return newState
    }

    static func reduceAddFavorite(action: AddFavorite, state: FavoritesState) -> FavoritesState {
        var newState = state
        newState.favoriteToEdit = action.favorite
        return newState
    }

    static func reduceEditFavorite(action: EditFavorite, state: FavoritesState) -> FavoritesState {
        var newState = state
        newState.favoriteToEdit = action.favorite
        return newState
    }

    static func reduceSaveFavorite(action: SaveEditedFavorite, state: FavoritesState) -> FavoritesState {
        var newState = state
        var favorite = action.favorite
        var favorites = removeFavorite(favorite, state: state)
        if favorite.favoriteId == Favorite.reversedFavoriteId {
            favorite.favoriteId = UUID().uuidString
            newState.reversedNextToArriveFavoriteId = favorite.favoriteId
        }

        favorites.append(favorite)
        newState.favorites = favorites
        newState.favoriteToEdit = nil
        return newState
    }

    static func reduceCancelFavoriteEdit(action _: CancelFavoriteEdit, state: FavoritesState) -> FavoritesState {
        var newState = state
        newState.favoriteToEdit = nil
        return newState
    }

    static func reduceRemoveFavorite(action: RemoveEditedFavorite, state: FavoritesState) -> FavoritesState {
        var newState = state
        newState.favorites = removeFavorite(action.favorite, state: state)
        return newState
    }

    static func reduceUpdateFavoriteNextToArriveTrips(action: UpdateFavoriteNextToArriveTrips, state: FavoritesState) -> FavoritesState {
        let updatedFavorites = updateFavoriteWithNextToArriveTrips(favoriteId: action.favoriteId, nextToArriveTrips: action.nextToArriveTrips, state: state)

        var newState = state
        newState.favorites = updatedFavorites
        return newState
    }

    static func reduceUpdateFavoriteNextToArriveUpdateStatus(action: UpdateFavoriteNextToArriveUpdateStatus, state: FavoritesState) -> FavoritesState {
        let updatedFavorites = updateFavoriteWithNextToArriveStatus(favoriteId: action.favoriteId, nextToArriveUpdateStatus: action.nextToArriveUpdateStatus, state: state)

        var newState = state
        newState.favorites = updatedFavorites
        return newState
    }

    static func reduceRequestFavoriteNextToArriveUpdate(action: RequestFavoriteNextToArriveUpdate, state: FavoritesState) -> FavoritesState {
        let updatedFavorites = updateFavoriteWithDataRefresh(favoriteId: action.favorite.favoriteId, refreshDataRequested: true, state: state)

        var newState = state
        newState.favorites = updatedFavorites
        return newState
    }

    static func reduceCreateNextToArriveFavorite(action: CreateNextToArriveFavorite, state: FavoritesState) -> FavoritesState {
        var newState = state
        newState.nextToArriveFavoriteId = action.favorite.favoriteId
        return newState
    }

    static func reduceUpdateNextToArriveDetailForFavorite(action: UpdateNextToArriveDetailForFavorite, state: FavoritesState) -> FavoritesState {
        guard var matchingFavorite = matchingFavoriteForId(action.favoriteId, state: state) else { return state }

        var newFavorites = nonMatchingFavoriteForId(action.favoriteId, state: state)
        var newTrips = [NextToArriveTrip]()
        for trip in matchingFavorite.nextToArriveTrips {
            var start = trip.startStop
            var end = trip.endStop

            if let startTripId = start.tripId, startTripId == action.tripId {
                start.addRealTimeData(nextToArriveDetail: action.realTimeArrivalDetail)
            } else if let endTripId = end.tripId, endTripId == action.tripId {
                end.addRealTimeData(nextToArriveDetail: action.realTimeArrivalDetail)
            }

            let newTrip = NextToArriveTrip(startStop: start, endStop: end, vehicleLocation: trip.vehicleLocation, connectionLocation: trip.connectionLocation)
            newTrips.append(newTrip)
        }
        matchingFavorite.nextToArriveTrips = newTrips
        newFavorites.append(matchingFavorite)

        var newState = state
        newState.favorites = newFavorites
        return newState
    }

    static func reduceUploadReversedFavorite(action: UploadReversedFavorite, state: FavoritesState) -> FavoritesState {
        var reversedFavorite = action.favorite

        if let matchingFavorite = matchingExistingFavoriteForReversedFavorite(favorite: reversedFavorite, state: state) {
            reversedFavorite = matchingFavorite
        }

        reversedFavorite.refreshDataRequested = true
        var newState = state
        newState.nextToArriveReverseTripStatus = .didReverse
        newState.reversedNextToArriveFavoriteId = reversedFavorite.favoriteId
        newState.favorites = replaceFavorite(reversedFavorite, state: state)
        return newState
    }

    static func reduceUndoReversedFavorite(action _: UndoReversedFavorite, state: FavoritesState) -> FavoritesState {
        var newState = state
        newState.nextToArriveReverseTripStatus = .noReverse
        newState.reversedNextToArriveFavoriteId = nil
        newState.favorites = state.favorites.filter { $0.favoriteId != Favorite.reversedFavoriteId }
        return newState
    }

    // MARK: - Helpers

    static func matchingFavoriteForId(_ favoriteId: String, state: FavoritesState) -> Favorite? {
        guard let matchingFavorite = state.favorites.filter({ $0.favoriteId == favoriteId }).first else { return nil }
        return matchingFavorite
    }

    static func matchingExistingFavoriteForReversedFavorite(favorite: Favorite, state: FavoritesState) -> Favorite? {
        guard let matchingFavorite = state.favorites.filter({
            $0.favoriteId != Favorite.reversedFavoriteId &&
                $0.selectedStart.stopId == favorite.selectedStart.stopId &&
                $0.selectedRoute.routeId == favorite.selectedRoute.routeId &&
                $0.selectedEnd.stopId == favorite.selectedEnd.stopId
        }).first else { return nil }
        return matchingFavorite
    }

    static func nonMatchingFavoriteForId(_ favoriteId: String, state: FavoritesState) -> [Favorite] {
        return state.favorites.filter { $0.favoriteId != favoriteId }
    }

    static func replaceFavorite(_ favorite: Favorite, state: FavoritesState) -> [Favorite] {
        var otherFavorites = state.favorites.filter { $0.favoriteId != favorite.favoriteId }
        otherFavorites.append(favorite)
        return otherFavorites
    }

    static func removeFavorite(_ favorite: Favorite, state: FavoritesState) -> [Favorite] {
        return state.favorites.filter { $0.favoriteId != favorite.favoriteId }
    }

    static func updateFavoriteWithNextToArriveTrips(favoriteId: String, nextToArriveTrips: [NextToArriveTrip], state: FavoritesState) -> [Favorite] {
        guard let matchingFavorite = matchingFavoriteForId(favoriteId, state: state) else { return state.favorites }
        var otherFavorites = nonMatchingFavoriteForId(favoriteId, state: state)
        let updatedFavorite = updateFavoriteWithNextToArriveTrips(favorite: matchingFavorite, nextToArriveTrips: nextToArriveTrips)
        otherFavorites.append(updatedFavorite)
        return otherFavorites
    }

    static func updateFavoriteWithNextToArriveTrips(favorite: Favorite, nextToArriveTrips: [NextToArriveTrip]) -> Favorite {
        var updatedFavorite = favorite
        updatedFavorite.nextToArriveTrips = nextToArriveTrips
        updatedFavorite.nextToArriveUpdateStatus = .dataLoadedSuccessfully
        updatedFavorite.refreshDataRequested = false
        return updatedFavorite
    }

    static func updateFavoriteWithNextToArriveStatus(favoriteId: String, nextToArriveUpdateStatus: NextToArriveUpdateStatus, state: FavoritesState) -> [Favorite] {
        guard var updatedFavorite = matchingFavoriteForId(favoriteId, state: state) else { return state.favorites }
        updatedFavorite.nextToArriveUpdateStatus = nextToArriveUpdateStatus
        updatedFavorite.refreshDataRequested = false
        if nextToArriveUpdateStatus == .noResultsReturned || nextToArriveUpdateStatus == .dataLoadingError {
            updatedFavorite.nextToArriveTrips = [NextToArriveTrip]()
        }
        var otherFavorites = nonMatchingFavoriteForId(favoriteId, state: state)

        otherFavorites.append(updatedFavorite)
        return otherFavorites
    }

    static func updateFavoriteWithDataRefresh(favoriteId: String, refreshDataRequested: Bool, state: FavoritesState) -> [Favorite] {
        guard var matchingFavorite = matchingFavoriteForId(favoriteId, state: state) else { return state.favorites }
        matchingFavorite.refreshDataRequested = refreshDataRequested
        var otherFavorites = nonMatchingFavoriteForId(favoriteId, state: state)

        otherFavorites.append(matchingFavorite)
        return otherFavorites
    }
}
