//
//  BaseNavigationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/4/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class BaseNavigationController: UINavigationController, UINavigationControllerDelegate, StoreSubscriber {
    typealias StoreSubscriberStateType = NavigationStackState?

    var transitionDelegate: UIViewControllerTransitioningDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribe()

        super.viewDidLoad()
        navigationBar.backgroundColor = UIColor.clear
        navigationBar.isTranslucent = true
        navigationBar.barStyle = .black
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }

    func subscribe() {
        // handled by subclasses
    }

    func newState(state: StoreSubscriberStateType) {
        guard let navAction = state else { return }
        presentModal(presentModal: navAction.presentModal)
        dismissModal(dismissModal: navAction.dismissModal)
        pushController(pushViewController: navAction.pushViewController)
        popController(popViewController: navAction.popViewController)
        resetViewState(resetViewState: navAction.resetViewState)
    }

    deinit {
        store.unsubscribe(self)
    }

    func getCurrentModalState() -> ViewController? {
        let presented = presentedViewController
        guard let modal = presented as? IdentifiableController else { return nil }
        return modal.viewController
    }

    func getCurrentViewControllerStack() -> [ViewController]? {
        let identifiableControllers: [ViewController?] = viewControllers.map {
            guard let identifiableController = $0 as? IdentifiableController else { return nil }
            return identifiableController.viewController
        }
        return identifiableControllers.compactMap { $0 }
    }

    func mapDisplayControllers() -> [ViewController] {
        guard let identifiableControllers = viewControllers as? [IdentifiableController] else { fatalError("All view controllers must be identifiable") }
        return identifiableControllers.map { $0.viewController }
    }

    func setRootViewController(viewController: ViewController) {
        let uiViewController = viewController.instantiateViewController()
        viewControllers = [uiViewController]
    }

    func presentModal(presentModal: PresentModal?) {
        guard let presentModal = presentModal else { return }
        let viewController = presentModal.viewController
        guard let transitionDelegate = viewController.transitioningDelegate() else { return }
        self.transitionDelegate = transitionDelegate
        let uiViewController = viewController.instantiateViewController()
        uiViewController.modalPresentationStyle = .custom
        uiViewController.transitioningDelegate = transitionDelegate
        present(uiViewController, animated: true)
        store.dispatch(PresentModalHandled())
    }

    func dismissModal(dismissModal: DismissModal?) {
        guard let _ = dismissModal else { return }
        dismiss(animated: true, completion: nil)
        store.dispatch(DismissModalHandled())
    }

    func pushController(pushViewController: PushViewController?) {
        guard let pushViewController = pushViewController else { return }
        let viewController = pushViewController.viewController
        let uiViewController = viewController.instantiateViewController()
        super.pushViewController(uiViewController, animated: true)
        store.dispatch(PushViewControllerHandled())
    }

    func popController(popViewController: PopViewController?) {
        guard let _ = popViewController else { return }
        super.popViewController(animated: true)
        store.dispatch(PopViewControllerHandled())
    }

    func replaceViewStack(viewControllers: [ViewController]) {
        var uiViewControllers = [UIViewController]()
        for viewController in viewControllers {
            uiViewControllers.append(viewController.instantiateViewController())
        }
        self.viewControllers = uiViewControllers
    }

    func retrieveOrInstantiate(viewControllers: [ViewController]) -> [UIViewController] {
        return viewControllers.map { ivc in
            if let matchingViewController = self.viewControllers.first(where: { vc in
                guard let vc = vc as? IdentifiableController, vc.viewController == ivc else { return false }
                return true
            }
            ) {
                return matchingViewController
            } else {
                return ivc.instantiateViewController()
            }
        }
    }

    func resetViewState(resetViewState _: ResetViewState?) {
//        dismiss(animated: false, completion: nil)
    }

    func appendToViewStack(viewControllers: [ViewController]) {
        var uiViewControllers = [UIViewController]()
        for viewController in viewControllers {
            uiViewControllers.append(viewController.instantiateViewController())
        }
        self.viewControllers.append(contentsOf: uiViewControllers)
    }

    func truncateViewStack(truncateLength: Int) {
        guard viewControllers.count < truncateLength else { return }
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
