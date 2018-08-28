//
//  NextToArriveFavoritesController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class NextToArriveFavoritesIconController: FavoritesState_FavoritesWatcherDelegate, ScheduleRequestWatcherDelegate {
    var editFavoriteBarButtonItem: UIBarButtonItem! {
        didSet {
            editFavoriteBarButtonItem.accessibilityLabel = "Edit Favorite"
        }
    }

    var navigationItem: UINavigationItem!
    var createFavoriteBarButtonItem: UIBarButtonItem! {
        didSet {
            createFavoriteBarButtonItem.accessibilityLabel = "Create Favorite"
        }
    }

    var refreshBarButtonItem: UIBarButtonItem! {
        didSet {
            refreshBarButtonItem.accessibilityLabel = "Refresh"
        }
    }

    var favoritesWatcher: FavoritesState_FavoritesWatcher!

    var scheduleRequestWatcher: BaseScheduleRequestWatcher!

    var currentScheduleRequest: ScheduleRequest?
    var currentFavorite: Favorite?

    init() {
        scheduleRequestWatcher = store.state.watcherForScheduleActions()
        favoritesWatcher = FavoritesState_FavoritesWatcher()
    }

    func favoritesState_FavoritesUpdated(favorites _: [Favorite]) {
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
        if store.state.currentTargetForScheduleActions() == .favorites {
            if let currentFavorite = currentFavorite, currentFavorite.favoriteId != Favorite.reversedFavoriteId {
                navigationItem.rightBarButtonItems = [editFavoriteBarButtonItem, refreshBarButtonItem]

            } else {
                navigationItem.rightBarButtonItems = [createFavoriteBarButtonItem, refreshBarButtonItem]
            }
        } else {
            navigationItem.rightBarButtonItems = [createFavoriteBarButtonItem, refreshBarButtonItem]
            if let _ = currentFavorite {
                createFavoriteBarButtonItem.image = SeptaImages.favoritesEnabled

            } else {
                createFavoriteBarButtonItem.image = SeptaImages.favoritesNotEnabled
            }
        }
    }
}
