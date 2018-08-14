//
//  TripDetailModalViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/13/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class TripDetailModalViewController: UIViewController, IdentifiableController {
    var viewController: ViewController = .tripDetailModalController

    override func viewDidLoad() {
        super.viewDidLoad()

        let controller = ViewController.tripDetailViewController.instantiateViewController()
        addChildViewController(controller)
        contentView.addSubview(controller.view)
        contentView.pinSubview(controller.view)
    }

    @IBOutlet var contentView: UIView!
    @IBAction func closeButtonTapped(sender _: UIButton) {
        store.dispatch(DismissModal(description: "Closing trip detail modal"))
    }
}
