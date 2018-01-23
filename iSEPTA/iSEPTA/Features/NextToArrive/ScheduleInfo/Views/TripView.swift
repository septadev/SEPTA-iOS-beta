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

    @IBAction func didTapView(_: Any) {
        guard !chevronView.isHidden else { return }
        backgroundColor = SeptaColor.buttonHighlight
        connectionView?.backgroundColor = SeptaColor.buttonHighlight
        isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15, execute: {
            self.backgroundColor = UIColor.white
            self.connectionView?.backgroundColor = UIColor.white
            let action = ShowTripDetails(nextToArriveStop: self.nextToArriveStop)
            store.dispatch(action)
            self.isUserInteractionEnabled = true
        })
    }

    var nextToArriveStop: NextToArriveStop!
    @IBOutlet var chevronView: LittleBlueChevronButton!
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
