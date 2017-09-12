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

    var tripHeaderView: TripHeaderView!
    @IBOutlet weak var tripHeaderWrapperView: UIView! {
        didSet {
            tripHeaderView = tripHeaderWrapperView.awakeInsertAndPinSubview(nibName: "TripHeaderView")
        }
    }

    var firstLegTripView: TripView!
    @IBOutlet weak var firstLegTripWrapper: UIView! {
        didSet {
            firstLegTripView = firstLegTripWrapper.awakeInsertAndPinSubview(nibName: "TripView")
        }
    }

    var secondLegTripView: TripView!
    @IBOutlet weak var secondLegTripWrapper: UIView! {
        didSet {
            secondLegTripView = secondLegTripWrapper.awakeInsertAndPinSubview(nibName: "TripView")
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
