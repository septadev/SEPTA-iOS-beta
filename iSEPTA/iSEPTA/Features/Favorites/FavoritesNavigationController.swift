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

class FavoritesNavigationController: UINavigationController, StoreSubscriber {
    typealias StoreSubscriberStateType = Bool

    override func viewDidLoad() {
        subscribe()
    }


    func newState(state: StoreSubscriberStateType) {
        let favoritesExist = state
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

    deinit {
        unsubscribe()
    }

    func retrieveStoryboardForViewController(_ viewController: ViewController) -> UIStoryboard {
        let storyboardString = viewController.storyboardIdentifier()
        return UIStoryboard(name: storyboardString, bundle: Bundle.main)
    }
}

import ReSwift

extension FavoritesNavigationController: SubscriberUnsubscriber {
    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.favoritesState.favoritesExist
            }.skipRepeats { $0 == $1 }
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
