//
//  HalfSheetPresentationCoordinator.swift
//  PresentationCoordinator
//
//  Created by Mark Broski on 9/15/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class DatePickerPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        var safeAreaBottom: CGFloat
        if #available(iOS 11.0, *) {
            safeAreaBottom = presentingViewController.view.safeAreaInsets.bottom
        } else {
            safeAreaBottom = 0
        }

        guard let containerView = containerView else { return CGRect(x: 0, y: 0, width: 0, height: 0) }
        let datePickerHeight = CGFloat(280.0)
        let containerHeight = (containerView.frame.height)
        let top = containerHeight - datePickerHeight - safeAreaBottom
        let finalFrame = CGRect(x: 0, y: top, width: containerView.bounds.width, height: datePickerHeight)
        return finalFrame
    }

    var dimmingView: UIView!

    func setupDimmingView() {
        dimmingView = UIView(frame: presentingViewController.view.bounds)
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.41)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(_:)))
        dimmingView.addGestureRecognizer(tapRecognizer)
    }

    @objc func dimmingViewTapped(_: UITapGestureRecognizer) {
        let action = DismissModal(description: "Dismissing modal by clicking in the dimming view")
        store.dispatch(action)
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
