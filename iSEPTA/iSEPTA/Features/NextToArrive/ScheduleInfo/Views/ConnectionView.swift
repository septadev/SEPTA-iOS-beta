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
    @IBOutlet var headerViewWrapper: UIView! {
        didSet {
            tripHeaderView = headerViewWrapper.awakeInsertAndPinSubview(nibName: "TripHeaderView")
            tripHeaderView.backgroundColor = UIColor.clear
            headerViewWrapper.backgroundColor = UIColor.clear
        }
    }

    var tripView: TripView!
    @IBOutlet var tripViewWrapper: UIView! {
        didSet {
            tripView = tripViewWrapper.awakeInsertAndPinSubview(nibName: "TripView")
            tripView.connectionView = self
        }
    }
}
