//
//  NextToArriveDetailViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class NextToArriveDetailViewController: UIViewController, IdentifiableController {

    @IBOutlet weak var tripView: UIView!
    static var viewController: ViewController = .nextToArriveDetailController

    override func viewDidLoad() {
        navigationController?.navigationBar.configureBackButton()
        view.backgroundColor = SeptaColor.navBarBlue
        navigationItem.title = store.state.nextToArriveState.scheduleState.scheduleRequest.transitMode.nextToArriveDetailTitle()
        view.bringSubview(toFront: tripView)
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

        if parent == navigationController?.parent {
            let action = UserPoppedViewController(description: "TripScheduleViewController has been popped")
            store.dispatch(action)
        }
    }
}
