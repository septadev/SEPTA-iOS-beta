//
//  SelectStopNavigationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/14/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import ReSwift

class SelectStopNavigationController: UINavigationController, IdentifiableController, IdentifiableNavController, StoreSubscriber {
    typealias StoreSubscriberStateType = [NavigationController: NavigationStackState]?

    static var navController: NavigationController = NavigationController.selectStop
    static var viewController: ViewController = .selectStopNavigationController

    let myStoryboard = UIStoryboard(name: NavigationController.schedules.storyboard(), bundle: Bundle.main)
    var lastStackState = NavigationStackState()
    var currentNavigationStackState = NavigationStackState()

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()
        initializeNavStackState()
    }

    func initializeNavStackState() {
        currentNavigationStackState = NavigationStackState(viewControllers: [.selectStopController], modalViewController: nil)
        let action = InitializeNavigationState(navigationController: .selectStop, navigationStackState: currentNavigationStackState, description: "Initialing Select Stop nav state")
        store.dispatch(action)
    }

    func newState(state: StoreSubscriberStateType) {

        guard let newState = state,
            let newStackState = newState[.selectStop], newStackState != lastStackState else { return }
        guard let existingViewControllers = currentNavigationStackState.viewControllers, let newViewControllers = newStackState.viewControllers else { return }
        if newViewControllers.count > existingViewControllers.count {
            guard let nextViewController = newViewControllers.last else { return }
            let viewController = myStoryboard.instantiateViewController(withIdentifier: nextViewController.rawValue)
            pushViewController(viewController, animated: true)
        } else {
            popViewController(animated: true)
        }

        currentNavigationStackState = newStackState
    }

    func subscribe() {

        store.subscribe(self) {
            $0.select {
                $0.navigationState.appStackState
            }
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
