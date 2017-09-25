//
//  TripHeaderView.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/11/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import SeptaSchedule

protocol AlertViewDelegate: AnyObject {
    func didTapAlertView(nextToArriveStop: NextToArriveStop, transitMode: TransitMode)
}

@IBDesignable
class TripHeaderView: UIView {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var pillView: UIView! {
        didSet {
            pillView.layer.cornerRadius = 4
        }
    }

    weak var alertViewDelegate: AlertViewDelegate?
    var nextToArriveStop: NextToArriveStop!
    var transitMode: TransitMode!

    @IBAction func didTapAlertView(_: Any) {
        if alertStackView.subviews.count > 0 {

            Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(twoSecondTimerFired(timer:)), userInfo: nil, repeats: false)
            activityIndicator.startAnimating()
            alertViewDelegate?.didTapAlertView(nextToArriveStop: nextToArriveStop, transitMode: transitMode)
        }
    }

    @objc func twoSecondTimerFired(timer: Timer) {
        activityIndicator.stopAnimating()
        timer.invalidate()
    }

    @IBOutlet weak var lineNameLabel: UILabel!
    @IBOutlet weak var alertStackView: UIStackView!
}
