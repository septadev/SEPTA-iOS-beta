//
//  SchedulesPresentationController.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class SlideInPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
func presentationController(forPresented presented: UIViewController,
                            presenting: UIViewController?,
                            source: UIViewController) -> UIPresentationController? {
  let presentationController = SlideInPresentationController(presentedViewController: presented,
                                                             presenting: presenting,
                                                             direction: direction)
  return presentationController
}
}

class SchedulesPresentationController: UIPresentationController {

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
    }

    fileprivate var dimmingView: UIView!
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        dimmingView.alpha = 0.0

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dimmingView.addGestureRecognizer(recognizer)
    }

    @objc dynamic func handleTap(recognizer _: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }

    override func presentationTransitionWillBegin() {

        // 1
        containerView?.insertSubview(dimmingView, at: 0)

        // 2
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView]))

        // 3
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }

    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }

    override func containerViewWillLayoutSubviews() {
  presentedView?.frame = frameOfPresentedViewInContainerView
}

override func size(forChildContentContainer container: UIContentContainer,
                   withParentContainerSize parentSize: CGSize) -> CGSize {
  return CGSize(width: parentSize.width, height: parentSize.height*(2.0/3.0))
}

override var frameOfPresentedViewInContainerView: CGRect {

  //1
  var frame: CGRect = .zero
  frame.size = size(forChildContentContainer: presentedViewController,
                    withParentContainerSize: containerView!.bounds.size)


  return frame
}
}

final class SlideInPresentationAnimator: NSObject {


}
