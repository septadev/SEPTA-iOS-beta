//
//  NextToArriveDetailViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class NextToArriveDetailViewController: UIViewController, IdentifiableController, UIGestureRecognizerDelegate {
    @IBOutlet var infoViewHeightCollapsedConstraint: NSLayoutConstraint!
    @IBOutlet var infoViewHeightExpandedConstraint: NSLayoutConstraint!

    @IBOutlet var upSwipeGestureRecognizer: UISwipeGestureRecognizer! {
        didSet {
            upSwipeGestureRecognizer.addTarget(self, action: #selector(NextToArriveDetailViewController.swipeAction(_:)))
        }
    }

    @IBOutlet var downSwipeGestureRecognizer: UISwipeGestureRecognizer! {
        didSet {
            downSwipeGestureRecognizer.addTarget(self, action: #selector(NextToArriveDetailViewController.swipeAction(_:)))
        }
    }

    @IBOutlet weak var tripView: UIView!
    static var viewController: ViewController = .nextToArriveDetailController

    var constraintsToggle: ConstraintsToggle!
    var gestureRecognizerToggle: SwipeGestureRecognizerToggle!

    override func viewDidLoad() {
        navigationController?.navigationBar.configureBackButton()
        view.backgroundColor = SeptaColor.navBarBlue
        navigationItem.title = store.state.nextToArriveState.scheduleState.scheduleRequest.transitMode.nextToArriveDetailTitle()
        view.bringSubview(toFront: tripView)
        constraintsToggle = ConstraintsToggle(activeConstraint: infoViewHeightCollapsedConstraint, inactiveConstraint: infoViewHeightExpandedConstraint)
        gestureRecognizerToggle = SwipeGestureRecognizerToggle(activeRecognizer: upSwipeGestureRecognizer, inactiveRecognizer: downSwipeGestureRecognizer)
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

        if parent == navigationController?.parent {
            let action = UserPoppedViewController(description: "TripScheduleViewController has been popped")
            store.dispatch(action)
        }
    }

    func toggleMapHeight() {
        constraintsToggle = constraintsToggle.toggleConstraints(inView: view)
        gestureRecognizerToggle = gestureRecognizerToggle.toggleRecognizers()
    }

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        guard let infoViewController = segue.destination as? NextToArriveInfoViewController else { return }
        infoViewController.nextToArriveDetailViewController = self
    }

    @IBAction func swipeAction(_: UISwipeGestureRecognizer) {

        toggleMapHeight()
    }

    func gestureRecognizer(_: UIGestureRecognizer, shouldReceive _: UITouch) -> Bool {
        print("Asking should receive touch")
        return true
    }

    func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        return true
    }
}
