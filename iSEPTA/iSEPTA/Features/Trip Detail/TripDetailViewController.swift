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

    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = store.state.tripDetailState.tripDetails?.routeName
    }
}
