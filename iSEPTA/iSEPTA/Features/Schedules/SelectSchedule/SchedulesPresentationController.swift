// Septa. 2017

import Foundation
import UIKit

class SlideInPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented: UIViewController,
                                presenting: UIViewController?,
                                source _: UIViewController) -> UIPresentationController? {

        return SchedulesPresentationController(presentedViewController: forPresented, presenting: presenting)
    }
}

class SchedulesPresentationController: UIPresentationController {
    let topMargin: CGFloat = 50
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

        containerView?.insertSubview(dimmingView, at: 0)

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView(151)]",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|",
                                           options: [], metrics: nil, views: ["dimmingView": dimmingView]))

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

    override func size(forChildContentContainer _: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: parentSize.height - topMargin)
    }

    override var frameOfPresentedViewInContainerView: CGRect {

        // 1
        var frame: CGRect = .zero
        frame.origin = CGPoint(x: 0, y: topMargin)
        frame.size = size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: containerView!.bounds.size)

        return frame
    }
}

final class SlideInPresentationAnimator: NSObject {
}
