//
//  ConnectionView.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class ConnectionView: UIView {
    var tripHeaderView: TripHeaderView!
    @IBOutlet weak var headerViewWrapper: UIView! {
        didSet {
            tripHeaderView = headerViewWrapper.awakeInsertAndPinSubview(nibName: "TripHeaderView")
        }
    }

    var tripView: TripView!
    @IBOutlet weak var tripViewWrapper: UIView! {
        didSet {
            tripView = headerViewWrapper.awakeInsertAndPinSubview(nibName: "TripView")
        }
    }
}
