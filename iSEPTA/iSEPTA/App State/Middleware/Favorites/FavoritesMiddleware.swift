//
//  FavoritesMiddleware.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift

let favoritesMiddleware: Middleware<AppState> = { _, _ in { next in
    return { action in
        if let action = action as? SeptaAction {
            if let action = action as? FavoritesMiddlewareAction {
                FavoritesMiddleware.generateActions(action: action)
            }
        }
        return next(action)
    }
}
}

class FavoritesMiddleware {
    static func generateActions(action: FavoritesMiddlewareAction) {
        switch action {
        case let action as SaveFavorite:
            generateActionsToSaveFavorite(action: action)
        case let action as RemoveFavorite:
            generateActionsToRemoveFavorite(action: action)
        default:
            break
        }
    }

    static func generateActionsToSaveFavorite(action: SaveFavorite) {
        let action = SaveEditedFavorite(favorite: action.favorite)
        store.dispatch(action)
        FavoritesProvider.sharedInstance.writeFavoritesToFile(state: store.state.favoritesState)
    }

    static func generateActionsToRemoveFavorite(action: RemoveFavorite) {
        let action = RemoveEditedFavorite(favorite: action.favorite)
        store.dispatch(action)
        FavoritesProvider.sharedInstance.writeFavoritesToFile(state: store.state.favoritesState)
    }
}
