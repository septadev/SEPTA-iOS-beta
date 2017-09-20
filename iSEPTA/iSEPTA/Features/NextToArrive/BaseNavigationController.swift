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
            let modalViewController = modal.instantiateViewController()
            modalViewController.modalPresentationStyle = .custom
            modalViewController.transitioningDelegate = slideInTransitioningDelegate
            present(modalViewController, animated: true)
        }
        if let _ = currentStackState.modalViewController, newStackState.modalViewController == nil {
            dismiss(animated: true, completion: nil)
            slideInTransitioningDelegate = SlideInPresentationManager()
        }

        if let newViewControllers = newStackState.viewControllers,
            let lastNewViewController = newViewControllers.last,
            let currentViewControllers = currentStackState.viewControllers {
            let uiControllersCount = viewControllers.count

            if uiControllersCount > newViewControllers.count {
                popViewController(animated: true)
            } else if uiControllersCount < newViewControllers.count {
                let newViewController = lastNewViewController.instantiateViewController()
                pushViewController(newViewController, animated: true)
            } else if uiControllersCount == newViewControllers.count && currentViewControllers != newViewControllers {
                rebuildViewControllerStack(newViewControllers: newStackState.viewControllers)
            }
        }

        if viewControllers.count == 0 {
            rebuildViewControllerStack(newViewControllers: newStackState.viewControllers)
        }

        currentStackState = newStackState
    }

    func rebuildViewControllerStack(newViewControllers: [ViewController]?) {
        guard let newViewControllers = newViewControllers else { return }
        var newControllersArray = [UIViewController]()

        for newViewController in newViewControllers {
            newControllersArray.append(newViewController.instantiateViewController())
        }
        viewControllers = newControllersArray
    }
}
