//
//  FavoriteState.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct FavoritesState: Codable, Equatable {
    var favorites: [Favorite]
    var favoriteToEdit: Favorite?

    var nextToArriveFavoriteId: String? = nil
    var reversedNextToArriveFavoriteId: String? = nil

    var hasFavoriteToEdit: Bool { return favoriteToEdit != nil }
    var favoritesExist: Bool { return favorites.count > 0 }

    var nextToArriveReverseTripStatus = NextToArriveReverseTripStatus.noReverse

    var nextToArriveTrips: [NextToArriveTrip] {
        guard let nextToArriveFavorite = nextToArriveFavorite else { return [NextToArriveTrip]() }
        return nextToArriveFavorite.nextToArriveTrips
    }

    var nextToArriveUpdateStatus: NextToArriveUpdateStatus {
        guard let nextToArriveFavorite = nextToArriveFavorite else { return .idle }
        return nextToArriveFavorite.nextToArriveUpdateStatus
    }

    var nextToArriveFavorite: Favorite? {
        if nextToArriveReverseTripStatus != .didReverse {
            return locateFavorite(favoriteId: nextToArriveFavoriteId)
        } else {
            return locateFavorite(favoriteId: reversedNextToArriveFavoriteId)
        }
    }

    func locateFavorite(favoriteId: String?) -> Favorite? {
        guard let favoriteId = favoriteId,
            let matchingFavorite = favorites.filter({ $0.favoriteId == favoriteId }).first else { return nil }
        return matchingFavorite
    }

    var nextToArriveScheduleRequest: ScheduleRequest {
        guard let nextToArriveFavorite = nextToArriveFavorite else { return ScheduleRequest() }
        return nextToArriveFavorite.convertedToScheduleRequest()
    }

    var favoritesToUpdate: Set<Favorite> {
        return Set(favorites.filter { $0.refreshDataRequested && $0.nextToArriveUpdateStatus != .dataLoading })
    }

    var favoritesToDisplay: Set<Favorite> {
        let filteredFavorites = favorites.filter { $0.favoriteId != Favorite.reversedFavoriteId }
        return Set(filteredFavorites)
    }

    init(favorites: [Favorite] = [Favorite](), favoriteToEdit: Favorite? = nil, nextToArriveFavoriteId: String? = nil) {
        self.favorites = favorites
        self.favoriteToEdit = favoriteToEdit
        self.nextToArriveFavoriteId = nextToArriveFavoriteId
    }

    enum CodingKeys: String, CodingKey {
        case favorites
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self) // defining our (keyed) container

        favorites = try container.decode([Favorite].self, forKey: .favorites)
        favoriteToEdit = nil
        nextToArriveFavoriteId = nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(favorites, forKey: .favorites)
    }
}


extension FavoritesState {
    func favoriteForScheduleRequest(_ scheduleRequest: ScheduleRequest) -> Favorite? {
        return favorites.filter({ $0 == scheduleRequest }).first
    }
}
