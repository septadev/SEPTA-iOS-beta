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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        navigationItem.title = "Rail Delay Detail"

        let barButtonItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(closeModal(sender:)))
        navigationItem.rightBarButtonItem = barButtonItem
    }

    @objc func closeModal(sender _: Any) {
        store.dispatch(ClearPushNotificationTripDetailData())
    }

    override func viewWillDisappear(_: Bool) {
    }
}
