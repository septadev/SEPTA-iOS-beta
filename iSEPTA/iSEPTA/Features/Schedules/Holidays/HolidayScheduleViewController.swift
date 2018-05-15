//
//  HolidayScheduleViewController.swift
//  HolidaySchedule
//
//  Created by Mark Broski on 12/14/17.
//  Copyright © 2017 Cap Tech. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class HolidayScheduleViewController: UIViewController {
    @IBOutlet var uiWebView: UIWebView!

    @IBAction func closeButtonTapped(_: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
