//
//  CustomPushNotificationsTimeframeView.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/27/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CustomPushNotificationsTimeframeView: UIView {
    @IBOutlet var timeframeLabel: UILabel! {
        didSet {
            guard let text = timeframeLabel.text else { return }
            timeframeLabel.attributedText = text.attributed(
                fontSize: 14,
                fontWeight: .bold,
                textColor: SeptaColor.black87,
                alignment: .left,
                kerning: 0.1,
                lineHeight: 24
            )
        }
    }

    @IBOutlet var centeringView: UIView! {
        didSet {
            centeringView.backgroundColor = UIColor.clear
        }
    }

    @IBOutlet var dividerView: UIView! {
        didSet {
            dividerView.backgroundColor = SeptaColor.gray_198
        }
    }

    @IBOutlet var startOfDay: TimeOfDayView!
    @IBOutlet var endOfDay: TimeOfDayView!

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 75)
    }
}
