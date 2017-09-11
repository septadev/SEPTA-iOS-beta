//
//  BaseFavoritesIconController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class BaseFavoritesIconController: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest
    let favoritesButton: UIButton
    weak var hostController: UIViewController!
    var scheduleRequest = ScheduleRequest() {
        didSet {
            updateFavoritesNavBarIcon()
        }
    }

    init(favoritesButton: UIButton, hostController: UIViewController) {
        self.favoritesButton = favoritesButton
        self.hostController = hostController
        setUpTargetAndActionForButton()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.nextToArriveState.scheduleState.scheduleRequest }.skipRepeats { $0 == $1 }
        }
    }

    func setUpTargetAndActionForButton() {
        favoritesButton.addTarget(self, action: #selector(NextToArriveFavoritesIconController.didTapFavoritesButton(_:)), for: UIControlEvents.touchUpInside)
    }

    @IBAction func didTapFavoritesButton(_: UIButton) {
        updateFavoritesStatus()
    }

    func updateFavoritesStatus() {
        guard let favorite = scheduleRequest.convertedToFavorite() else { return }

        if scheduleRequest.isFavorited() {
            requestPermissionToRemoveFavorite(favorite: favorite)
        } else {
            requestPermissionToAddFavorite(favorite: favorite)
        }
    }

    func requestPermissionToAddFavorite(favorite: Favorite) {
        UIAlert.presentYesNoAlertFrom(viewController: hostController, withTitle: "Add a Favorite?", message: "Would you like to add this trip as a favorite?") { [weak self] in
            guard let strongSelf = self else { return }
            let action = AddFavorite(favorite: favorite)
            store.dispatch(action)
            strongSelf.updateFavoritesNavBarIcon()
        }
    }

    func requestPermissionToRemoveFavorite(favorite: Favorite) {
        UIAlert.presentDestructiveYesNoAlertFrom(viewController: hostController, withTitle: "Remove a Favorite?", message: "Would you like to remove this trip as a favorite?") { [weak self] in
            guard let strongSelf = self else { return }
            let action = RemoveFavorite(favorite: favorite)
            store.dispatch(action)
            strongSelf.updateFavoritesNavBarIcon()
        }
    }

    func updateFavoritesNavBarIcon() {
        let image: UIImage
        if scheduleRequest.isFavorited() {
            image = SeptaImages.favoritesEnabled
        } else {
            image = SeptaImages.favoritesNotEnabled
        }
        favoritesButton.setImage(image, for: UIControlState.normal)
    }

    func newState(state: StoreSubscriberStateType) {
        scheduleRequest = state
    }

    deinit {
        store.unsubscribe(self)
    }
}
