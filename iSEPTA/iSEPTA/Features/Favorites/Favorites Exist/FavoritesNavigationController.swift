//
//  FavoritesNavigationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class FavoritesNavigationController: BaseNavigationController, FavoritesState_FavoritesExistWatcherDelegate {
    typealias StoreSubscriberStateType = Bool
    var favoritesWatcher: FavoritesState_FavoritesExistWatcher!

    override func awakeFromNib() {
        super.awakeFromNib()
        favoritesWatcher = FavoritesState_FavoritesExistWatcher(delegate: self)
    }

    func favoritesState_FavoritesExistUpdated(bool: Bool) {
        let favoritesExist = bool
        if favoritesExist {
            showFavoritesController()
        } else {
            showNoFavoritesViewController()
        }
    }

    func showFavoritesController() {

        initializeNavStackState(viewController: .favoritesViewController)
    }

    func showNoFavoritesViewController() {

        initializeNavStackState(viewController: .noFavoritesViewController)
    }

    func initializeNavStackState(viewController: ViewController) {
        let navigationStackState = NavigationStackState(viewControllers: [viewController], modalViewController: nil)
        let action = InitializeNavigationState(navigationController: .favorites, navigationStackState: navigationStackState, description: "Initialiazing Favorites nav stack state")
        store.dispatch(action)
    }
}
