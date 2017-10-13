//
//  NextToArriveDetailViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class TripDetailViewController: UIViewController, IdentifiableController {

    let viewController = ViewController.tripDetailViewController

    var tripDetails: NextToArriveStop? { return store.state.tripDetailState.tripDetails }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
        guard let tripDetails = tripDetails else { return }
        navigationItem.title = tripDetails.transitMode.tripDetailTitle()
    }

    override func viewWillDisappear(_: Bool) {
        let action = ClearTripDetails()
        store.dispatch(action)
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        backButtonPopped(toParentViewController: parent)
    }
}
