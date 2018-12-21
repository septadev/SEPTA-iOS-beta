//
//  FavoritesNavigationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class FavoritesNavigationController: BaseNavigationController, FavoritesState_FavoritesExistWatcherDelegate {
    typealias StoreSubscriberStateType = Bool
    var favoritesWatcher: FavoritesState_FavoritesExistWatcher!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
    }

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

    override func subscribe() {
        store.subscribe(self) {
            $0.select { $0.navigationState.appStackState[.favorites] }
        }
    }

    func showFavoritesController() {
        setRootViewController(viewController: .favoritesViewController)
    }

    func showNoFavoritesViewController() {
        setRootViewController(viewController: .noFavoritesViewController)
    }
}
