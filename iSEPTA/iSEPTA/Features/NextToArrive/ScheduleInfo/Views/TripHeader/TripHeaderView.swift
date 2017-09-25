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
            alertViewDelegate?.didTapAlertView(nextToArriveStop: nextToArriveStop, transitMode: transitMode)
        }
    }

    @IBOutlet weak var lineNameLabel: UILabel!
    @IBOutlet weak var alertStackView: UIStackView!
}
