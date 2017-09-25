//
//  BaseNavigationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class BaseNavigationController: UINavigationController, UINavigationControllerDelegate {
    var currentStackState = NavigationStackState()

    @IBOutlet var stateProvider: NavigationControllerBaseStateProvider!
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()

    func newStackState(_ newStackState: NavigationStackState) {

        handleModalState(newModalViewController: newStackState.modalViewController)
        handleViewControllerState(newControllers: newStackState.viewControllers)
        currentStackState = newStackState
    }

    func handleModalState(newModalViewController: ViewController?) {
        let model = NavigationModalStateToNavigationEvent(currentModal: currentStackState.modalViewController, newModal: newModalViewController)
        switch model.determineNecessaryStateAction() {
        case .noActionNeeded:
            break
        case let .presentModal(viewController):
            presentModal(viewController: viewController)
        case .dismissModal:
            dismissModal()
        case let .dismissThenPresent(viewController):
            dismissModal()
            presentModal(viewController: viewController)
        }
    }

    func handleViewControllerState(newControllers: [ViewController]) {

        let displayControllers = mapDisplayControllers()
        let model = NavigationViewControllerStateToNavigationEvent(currentControllers: currentStackState.viewControllers, newControllers: newControllers, displayControllers: displayControllers)

        switch model.determineNecessaryStateAction() {
        case .noActionNeeded:
            break
        case let .rootViewController(viewController):
            setRootViewController(viewController: viewController)
        case let .push(viewController):
            pushController(viewController: viewController)
        case .pop:
            popController()
        case .systemPop:
            break
        case let .replaceViewStack(viewControllers):
            replaceViewStack(viewControllers: viewControllers)
        case let .appendToViewStack(viewControllers):
            appendToViewStack(viewControllers: viewControllers)
        case let .truncateViewStack(truncateLength):
            truncateViewStack(truncateLength: truncateLength)
        }
    }

    func mapDisplayControllers() -> [ViewController] {
        guard let identifiableControllers = viewControllers as? [IdentifiableController] else { fatalError("All view controllers must be identifiable") }
        return identifiableControllers.map { $0.viewController }
    }

    func setRootViewController(viewController: ViewController) {
        let uiViewController = viewController.instantiateViewController()
        viewControllers = [uiViewController]
    }

    var transitionDelegate: UIViewControllerTransitioningDelegate?

    func presentModal(viewController: ViewController) {
        guard let transitionDelegate = viewController.transitioningDelegate() else { return }
        self.transitionDelegate = transitionDelegate
        let uiViewController = viewController.instantiateViewController()
        uiViewController.modalPresentationStyle = .custom
        uiViewController.transitioningDelegate = transitionDelegate
        present(uiViewController, animated: true)
    }

    func dismissModal() {
        dismiss(animated: true, completion: nil)
    }

    func pushController(viewController: ViewController) {
        let uiViewController = viewController.instantiateViewController()
        pushViewController(uiViewController, animated: true)
    }

    func popController() {
        popViewController(animated: true)
    }

    func replaceViewStack(viewControllers: [ViewController]) {
        var uiViewControllers = [UIViewController]()
        for viewController in viewControllers {
            uiViewControllers.append(viewController.instantiateViewController())
        }
        self.viewControllers = uiViewControllers
    }

    func appendToViewStack(viewControllers: [ViewController]) {
        var uiViewControllers = [UIViewController]()
        for viewController in viewControllers {
            uiViewControllers.append(viewController.instantiateViewController())
        }
        self.viewControllers.append(contentsOf: uiViewControllers)
    }

    func truncateViewStack(truncateLength: Int) {
        let truncated = viewControllers[..<truncateLength]
        viewControllers = Array(truncated)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        delegate = self
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
        navigationController.navigationBar.tintColor = UIColor.white
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        viewController.navigationItem.backBarButtonItem = item
    }
}
