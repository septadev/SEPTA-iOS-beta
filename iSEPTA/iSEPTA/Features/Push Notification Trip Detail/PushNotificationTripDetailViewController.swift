//
//  NextToArriveDetailViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class PushNotificationTripDetailViewController: UIViewController, IdentifiableController {
    let viewController = ViewController.pushNotificationTripDetailViewController

    var tripDetails: NextToArriveStop? { return store.state.tripDetailState.tripDetails }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
        guard let tripDetails = tripDetails else { return }
        navigationItem.title = "Rail Delay Notification"
    }

    override func viewWillDisappear(_: Bool) {

    }
}
