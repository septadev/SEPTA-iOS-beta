//
//  HalfSheetAnimationIn.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/16/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class SevenEightsAnimationIn: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }

    var presenting = true

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!

        let toView = toViewController.view!
        let container = transitionContext.containerView
        let containerViewHeight = container.frame.size.height
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let startingFrame = finalFrame.offsetBy(dx: 0, dy: containerViewHeight)
        toView.frame = startingFrame
        container.addSubview(toView)

        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            toView.frame = transitionContext.finalFrame(for: toViewController)
        }, completion: { _ in

            transitionContext.completeTransition(true)

        })
    }
}
