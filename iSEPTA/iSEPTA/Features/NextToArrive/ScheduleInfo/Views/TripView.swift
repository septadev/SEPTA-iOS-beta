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

    @IBAction func didTapView(_: Any) {
        guard !chevronView.isHidden else { return }
        backgroundColor = SeptaColor.buttonHighlight
        connectionView?.backgroundColor = SeptaColor.buttonHighlight
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
            self.backgroundColor = UIColor.white
            self.connectionView?.backgroundColor = UIColor.white
        })
    }

    @IBOutlet weak var chevronView: LittleBlueChevronButton!
    @IBOutlet weak var departingWhenLabel: UILabel!
    @IBOutlet weak var startStopLabel: UILabel!
    @IBOutlet weak var onTimeLabel: UILabel!
    @IBOutlet weak var endStopLabel: UILabel!

    weak var connectionView: ConnectionView?

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 58)
    }
}
