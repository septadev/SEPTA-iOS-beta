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
        case let action as RemoveFavorite:
            favoritesState = reduceRemoveFavorite(action: action, state: state)

        default:
            break
        }

        return favoritesState
    }

    static func reduceLoadFavorites(action: LoadFavorites, state _: FavoritesState) -> FavoritesState {
        return FavoritesState(favorites: action.favorites)
    }

    static func reduceAddFavorite(action: AddFavorite, state: FavoritesState) -> FavoritesState {
        var favorites = state.favorites
        favorites.append(action.favorite)
        return FavoritesState(favorites: favorites)
    }

    static func reduceRemoveFavorite(action: RemoveFavorite, state: FavoritesState) -> FavoritesState {
        let favorites = state.favorites.filter { $0 != action.favorite }
        return FavoritesState(favorites: favorites)
    }
}
