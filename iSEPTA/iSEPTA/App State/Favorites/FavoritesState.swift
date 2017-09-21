//
//  FavoriteState.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

struct FavoritesState: Codable {
    let favorites: [Favorite]
    var favoriteToEdit: Favorite?
    var nextToArriveFavorite: Favorite?
    var hasFavoriteToEdit: Bool { return favoriteToEdit != nil }
    var hasNextToArriveFavorite: Bool { return nextToArriveFavorite != nil }
    var favoritesExist: Bool { return favorites.count > 0 }
    var favoritesToUpdate: Set<Favorite> {
        return Set(favorites.filter { $0.refreshDataRequested && $0.nextToArriveUpdateStatus != .dataLoading })
    }
    var favoritesToDisplay: Set<Favorite> { return
        //  Set(favorites.filter { $0.nextToArriveUpdateStatus == .dataLoadedSuccessfully })
        Set(favorites)
    }

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
    var areEqual = true

    areEqual = lhs.favorites == rhs.favorites
    guard areEqual else { return false }

    areEqual = lhs.favoritesExist == rhs.favoritesExist
    guard areEqual else { return false }

    areEqual = lhs.favoritesToDisplay == rhs.favoritesToDisplay
    guard areEqual else { return false }

    areEqual = lhs.favoritesToUpdate == rhs.favoritesToUpdate
    guard areEqual else { return false }

    return areEqual
}

extension FavoritesState {
    func favoriteForScheduleRequest(_ scheduleRequest: ScheduleRequest) -> Favorite? {
        return favorites.filter({ $0 == scheduleRequest }).first
    }
}
