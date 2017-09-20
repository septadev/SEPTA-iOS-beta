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

    var favoritesButton: UIButton! {
        didSet {
            setUpTargetAndActionForButton()
            favoritesWatcher.delegate = self
            scheduleRequestWatcher?.delegate = self
        }
    }

    var favoritesWatcher: FavoritesState_FavoritesWatcher! {
        didSet {
        }
    }

    var scheduleRequestWatcher: BaseScheduleRequestWatcher?

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

    func setUpTargetAndActionForButton() {
        favoritesButton.addTarget(self, action: #selector(NextToArriveFavoritesIconController.didTapFavoritesButton(_:)), for: UIControlEvents.touchUpInside)
    }

    @IBAction func didTapFavoritesButton(_: UIButton) {
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
        let image: UIImage
        if let _ = currentFavorite {
            image = SeptaImages.favoritesEnabled
        } else {
            image = SeptaImages.favoritesNotEnabled
        }
        favoritesButton.setImage(image, for: UIControlState.normal)
    }
}
