//
//  HalfSheetPresentationCoordinator.swift
//  PresentationCoordinator
//
//  Created by Mark Broski on 9/15/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class HalfSizePresentationController: UIPresentationController {

    override var frameOfPresentedViewInContainerView: CGRect {
        var safeAreaTop: CGFloat = 0
        if #available(iOS 11.0, *) {
            safeAreaTop = presentingViewController.view.safeAreaInsets.top
        } else {
            safeAreaTop = presentingViewController.topLayoutGuide.length
        }

        guard let containerView = containerView else { return CGRect(x: 0, y: 0, width: 0, height: 0) }
        return CGRect(x: 0, y: 0, width: containerView.bounds.width, height: 299 + safeAreaTop)
    }

    var dimmingView: UIView!

    func setupDimmingView() {
        dimmingView = UIView(frame: presentingViewController.view.bounds)
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.41)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(_:)))
        dimmingView.addGestureRecognizer(tapRecognizer)
    }

    @objc func dimmingViewTapped(_: UITapGestureRecognizer) {
        let action = CancelFavoriteEdit()
        store.dispatch(action)
        presentingViewController.dismiss(animated: true, completion: nil)
    }

    override func presentationTransitionWillBegin() {
        setupDimmingView()
        guard let containerView = self.containerView else { return }
        let presentedViewController = self.presentedViewController

        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0.0

        containerView.insertSubview(dimmingView, at: 0)
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) -> Void in
            self.dimmingView.alpha = 1.0
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (_) -> Void in
            self.dimmingView.alpha = 0.0
        }, completion: nil)
    }
}
