//
//  BaseNavigationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

enum NavigationActionNeeded {
  case noActionNeeded
  case  initializingViewState
  case     presentModal
  case     dismissModal
  case      push
  case      pop
  case     rebuildNeeded
  case     systemPop

}

class BaseNavigationController: UINavigationController {
    var currentStackState = NavigationStackState()

    var currentControllers : [ViewController] {
        return currentStackState.viewControllers ?? [ViewController]()
    }



    @IBOutlet var stateProvider: NavigationControllerBaseStateProvider!
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()

    func newStackState(_ newStackState: NavigationStackState) {
        guard newStackState != currentStackState else { return }

        let navigationActionNeeded = determineNavigationActionNeeded(newStackState)

        switch navigationActionNeeded {
            case presentModal: presentModal(stackState: newStackState)

            case dismissModal: dismissModal()

            case push:



        }
        if let modal = newStackState.modalViewController {

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


    func presentModal(stackState: NavigationStackState) {
        guard let modal = stackState.modalViewController else { return }
        let modalViewController = modal.instantiateViewController()
            modalViewController.modalPresentationStyle = .custom
            modalViewController.transitioningDelegate = slideInTransitioningDelegate
            present(modalViewController, animated: true)

    }

    func dismissModal() {
        dismiss(animated: true, completion: nil)
    }

    func pushViewController(stackState: NavigationStackState){
        guard let viewControllers = stackState.viewControllers, lastViewController = viewControllers.last else { return }
        let uiViewController = lastViewController.instantiateViewController()
        pushViewController(uiViewController, animated: true)

    }

    func popViewController(stackState: NavigationStackState){
        popViewController(animated: true)

    }

    func rebuildViewControllerStack(newViewControllers: [ViewController]) {
        guard let identifiableControllers = self.viewControllers as? [IdentifiableController] else { return }
        let newUIViewControllersArray =
        for (index, element) in newViewControllers.enumerate() {
            print("Item \(index): \(element)")
        }


    }

    func determineNavigationActionNeeded(newStackState: NavigationStackState) -> NavigationActionType {
        guard let identifiableControllers = self.viewControllers as? [IdentifiableController],
        let newStackStateViewControllers = newStackState.viewControllers else { fatalError() }
        let currentControllers: [ViewController] = identifiableControllers.map { $0.viewController }

        if identifiableControllers.count == 0 {
            return .initializingViewState
        }

        else if currentStackState.modalViewController == nil && newStackState.modalViewController != nil {
            return .presentModal
        }

        else if currentStackState.modalViewController != nil && newStackState.modalViewController == nil {
            return .dismissModal
        }

        else if currentControllers == newStackStateViewControllers {
            return .systemPop
        }

        else if currentControllers != newStackStateViewControllers && currentControllers.count < newStackStateViewControllers.count{
            return .push
        }

         else if currentControllers != newStackStateViewControllers && currentControllers.count > newStackStateViewControllers.count {
            return .pop
        }


        return .rebuildNeeded


    }


}
