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

class FavoritesNavigationController: UINavigationController, FavoritesState_FavoritesExistWatcherDelegate {
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
        let controller = loadViewController(.favoritesViewController)
        makeRootViewController(controller)
    }

    func showNoFavoritesViewController() {

        let controller = loadViewController(.noFavoritesViewController)
        makeRootViewController(controller)
    }

    func makeRootViewController(_ viewController: UIViewController) {
        viewControllers = [viewController]
    }

    func loadViewController(_ viewController: ViewController) -> UIViewController {
        let storyboard = retrieveStoryboardForViewController(viewController)
        return storyboard.instantiateViewController(withIdentifier: viewController.rawValue)
    }

    func retrieveStoryboardForViewController(_ viewController: ViewController) -> UIStoryboard {
        let storyboardString = viewController.storyboardIdentifier()
        return UIStoryboard(name: storyboardString, bundle: Bundle.main)
    }
}
