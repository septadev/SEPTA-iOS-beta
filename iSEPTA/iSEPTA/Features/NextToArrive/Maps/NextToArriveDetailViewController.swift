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

    static var viewController: ViewController = .nextToArriveDetailController

    override func viewDidLoad() {
        navigationController?.navigationBar.configureBackButton()

        navigationItem.title = store.state.nextToArriveState.scheduleState.scheduleRequest.transitMode.nextToArriveDetailTitle()
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

        if parent == navigationController?.parent {
            let action = UserPoppedViewController(description: "TripScheduleViewController has been popped")
            store.dispatch(action)
        }
    }
}
