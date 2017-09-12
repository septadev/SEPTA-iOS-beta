//
//  ConnectionCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class ConnectionCell: UITableViewCell {

    var startConnectionView: ConnectionView!
    @IBOutlet weak var startConnectionViewWrapper: UIView! {
        didSet {
            startConnectionView = startConnectionViewWrapper.awakeInsertAndPinSubview(nibName: "ConnectionView")
        }
    }

    var endConnectionView: ConnectionView!
    @IBOutlet weak var endConnectionViewWrapper: UIView! {
        didSet {
            endConnectionView = endConnectionViewWrapper.awakeInsertAndPinSubview(nibName: "ConnectionView")
        }
    }

    //    @IBOutlet weak var startingTripWrapperView: UIView! {
    //        didSet {
    //            connectionView = startingTripWrapperView.awakeInsertAndPinSubview(nibName: "ConnectionView")
    //            startingTripView = connectionView.tripView
    //        }
    //    }
    //    var startingTripView: TripView!
    //    var tripView: TripHeaderView!
    //    var endingTripView: TripView!
    //    @IBOutlet weak var endingTripWrapperView: UIView! {
    //        didSet {
    //            endingTripView = endingTripWrapperView.awakeInsertAndPinSubview(nibName: "TripView")
    //        }
    //    }
    //
    @IBOutlet weak var connectionLabel: UILabel!
}

class BlueGradientView: UIView {

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawConnectingGradientView(frame: rect)
    }
}
