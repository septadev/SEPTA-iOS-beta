//
//  TripView.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class TripView: UIView {

    @IBOutlet var departingBox: UIView! {
        didSet {
            departingBox.layer.cornerRadius = 2.0
            departingBox.layer.borderWidth = 1.0
        }
    }

    var nextToArriveStop: NextToArriveStop!
    @IBOutlet var departingWhenLabel: UILabel!
    @IBOutlet var startStopLabel: UILabel!
    @IBOutlet var onTimeLabel: UILabel! {

        didSet {
            onTimeLabel.text = "Scheduled"
        }
    }

    @IBOutlet var endStopLabel: UILabel!

    weak var connectionView: ConnectionView?

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 58)
    }
}
