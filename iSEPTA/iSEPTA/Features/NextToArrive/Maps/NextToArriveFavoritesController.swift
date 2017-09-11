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

class NextToArriveFavoritesIconController: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest
    let favoritesBarButtonItem: UIBarButtonItem

    var scheduleRequest = ScheduleRequest() {
        didSet {
            updateFavoritesNavBarIcon()
        }
    }

    init(favoritesBarButtonItem: UIBarButtonItem) {
        self.favoritesBarButtonItem = favoritesBarButtonItem
        setUpTargetAndActionForBarButtonItem()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.nextToArriveState.scheduleState.scheduleRequest }.skipRepeats { $0 == $1 }
        }
    }

    func setUpTargetAndActionForBarButtonItem() {
        favoritesBarButtonItem.target = self
        favoritesBarButtonItem.action = #selector(TripScheduleFavoritesIconController.favoritesIconTapped(_:))
    }

    @objc func favoritesIconTapped(_: Any) {
        guard let favorite = scheduleRequest.convertedToFavorite() else { return }
        let action: FavoritesAction
        if scheduleRequest.isFavorited() {
            action = RemoveFavorite(favorite: favorite)
        } else {
            action = AddFavorite(favorite: favorite)
        }

        store.dispatch(action)
        updateFavoritesNavBarIcon()
    }

    func updateFavoritesNavBarIcon() {
        let image: UIImage
        if scheduleRequest.isFavorited() {
            image = SeptaImages.favoritesEnabled
        } else {
            image = SeptaImages.favoritesNotEnabled
        }
        favoritesBarButtonItem.setBackgroundImage(image, for: .normal, barMetrics: UIBarMetrics.default)
    }

    func newState(state: StoreSubscriberStateType) {
        scheduleRequest = state
    }

    deinit {
        store.unsubscribe(self)
    }
}
