//
//  NextToArriveFavoritesController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class NextToArriveFavoritesIconController: FavoritesState_FavoritesWatcherDelegate, ScheduleRequestWatcherDelegate {

    var editFavoriteBarButtonItem: UIBarButtonItem!
    var navigationItem: UINavigationItem!
    var createFavoriteBarButtonItem: UIBarButtonItem!

    var favoritesWatcher: FavoritesState_FavoritesWatcher!

    var scheduleRequestWatcher: BaseScheduleRequestWatcher!

    var currentScheduleRequest: ScheduleRequest?
    var currentFavorite: Favorite?

    init() {
        scheduleRequestWatcher = store.state.watcherForScheduleActions()
        favoritesWatcher = FavoritesState_FavoritesWatcher()
    }

    func favoritesState_FavoritesUpdated(favorites _: [Favorite]) {
        if store.state.targetForScheduleActions() == .favorites && store.state.favoritesState.nextToArriveFavoriteId == nil {
            let action = UserPoppedViewController(description: "Can't show more when there are no favorites")
            store.dispatch(action)
        }
        guard let currentScheduleRequest = currentScheduleRequest else { return }
        currentFavorite = currentScheduleRequest.locateInFavorites()

        updateFavoritesNavBarIcon()
    }

    func scheduleRequestUpdated(scheduleRequest: ScheduleRequest) {
        currentScheduleRequest = scheduleRequest
        currentFavorite = scheduleRequest.locateInFavorites()
        updateFavoritesNavBarIcon()
    }

    func setUpTargets() {
        setUpTargetAndActionForEditFavoriteButton()
        setUpTargetAndActionForCreateFavoriteButton()
        scheduleRequestWatcher.delegate = self
        favoritesWatcher.delegate = self
    }

    func setUpTargetAndActionForEditFavoriteButton() {
        editFavoriteBarButtonItem.action = #selector(didTapFavoritesButton)
        editFavoriteBarButtonItem.target = self
    }

    func setUpTargetAndActionForCreateFavoriteButton() {
        createFavoriteBarButtonItem.action = #selector(didTapFavoritesButton)
        createFavoriteBarButtonItem.target = self
    }

    @objc func didTapFavoritesButton() {
        if let currentFavorite = currentFavorite {
            let action = EditFavorite(favorite: currentFavorite)
            store.dispatch(action)
        } else {
            guard let newFavorite = currentScheduleRequest?.convertedToFavorite() else { return }
            let action = AddFavorite(favorite: newFavorite)
            store.dispatch(action)
        }
    }

    func updateFavoritesNavBarIcon() {
        navigationItem.rightBarButtonItems?.removeAll()

        if let _ = currentFavorite {
            navigationItem.rightBarButtonItem = editFavoriteBarButtonItem
        } else {
            navigationItem.rightBarButtonItem = createFavoriteBarButtonItem
        }
    }
}
