//
//  CustomPushNotificationsTimeframeView.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/27/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class CustomPushNotificationsTimeframeView: UIView {
    @IBOutlet var timeframeLabel: UILabel!
    @IBOutlet var startValueLabel: UILabel!
    @IBOutlet var untilValueLabel: UILabel!

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 75)
    }
}
