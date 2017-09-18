//
//  BaseNavigationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class BaseNavigationController: UINavigationController {
    var currentStackState = NavigationStackState()

    @IBOutlet var stateProvider: NavigationControllerBaseStateProvider!
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()

    func newStackState(_ newStackState: NavigationStackState) {
        guard newStackState != currentStackState else { return }
        if let modal = newStackState.modalViewController {
            let storyboard = retrieveStoryboardForViewController(modal)
            let viewController = storyboard.instantiateViewController(withIdentifier: modal.rawValue)
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = slideInTransitioningDelegate
            present(viewController, animated: true)
        }
        if let _ = currentStackState.modalViewController, newStackState.modalViewController == nil {
            dismiss(animated: true, completion: nil)
            slideInTransitioningDelegate = SlideInPresentationManager()
        }

        if let newViewControllers = newStackState.viewControllers,
            let lastNewViewController = newViewControllers.last {
            let uiControllersCount = viewControllers.count

            if uiControllersCount > newViewControllers.count {
                popViewController(animated: true)
            } else if uiControllersCount < newViewControllers.count {
                let storyboard = retrieveStoryboardForViewController(lastNewViewController)
                let newViewController = storyboard.instantiateViewController(withIdentifier: lastNewViewController.rawValue)
                pushViewController(newViewController, animated: true)
            }
        }

        currentStackState = newStackState
    }

    func retrieveStoryboardForViewController(_ viewController: ViewController) -> UIStoryboard {
        let storyboardString = viewController.storyboardIdentifier()
        return UIStoryboard(name: storyboardString, bundle: Bundle.main)
    }
}
