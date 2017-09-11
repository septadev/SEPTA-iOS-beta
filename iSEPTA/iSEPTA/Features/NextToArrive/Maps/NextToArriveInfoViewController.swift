//
//  NextToArriveInfoViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class NextToArriveInfoViewController: UIViewController {

    @IBOutlet var upSwipeGestureRecognizer: UISwipeGestureRecognizer!
    @IBOutlet var downSwipeGestureRecognizer: UISwipeGestureRecognizer!

    weak var nextToArriveDetailViewController: NextToArriveDetailViewController?

    override func viewDidLoad() {

        nextToArriveDetailViewController?.upSwipeGestureRecognizer = upSwipeGestureRecognizer
        nextToArriveDetailViewController?.downSwipeGestureRecognizer = downSwipeGestureRecognizer
    }
}
