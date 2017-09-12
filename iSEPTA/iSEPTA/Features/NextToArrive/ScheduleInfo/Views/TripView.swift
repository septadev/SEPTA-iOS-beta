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

    @IBOutlet weak var departingBox: UIView! {
        didSet {
            departingBox.layer.cornerRadius = 2.0
            departingBox.layer.borderWidth = 1.0
        }
    }

    @IBOutlet weak var departingWhenLabel: UILabel!
    @IBOutlet weak var startStopLabel: UILabel!
    @IBOutlet weak var onTimeLabel: UILabel!
    @IBOutlet weak var endStopLabel: UILabel!
}
