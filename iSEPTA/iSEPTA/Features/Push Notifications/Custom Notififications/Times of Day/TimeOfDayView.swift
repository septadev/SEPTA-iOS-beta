//
//  TimeOfDayView.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/30/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class TimeOfDayView: UIView {
    @IBOutlet var headingLabel: UILabel! {
        didSet {
            guard let text = headingLabel.text else { return }
            setHeadingLabel(text: text)
        }
    }

    @IBOutlet var timeOfDayLabel: UILabel! {
        didSet {
            guard let text = timeOfDayLabel.text else { return }
            setTimeOfDayLabel(text: text)
        }
    }

    func setTimeOfDayLabel(text: String) {
        timeOfDayLabel.attributedText = text.attributed(
            fontSize: 14,
            fontWeight: .bold,
            textColor: SeptaColor.blue_27_78_142,
            alignment: .left,
            kerning: 0.1,
            lineHeight: 24
        )
    }

    func setHeadingLabel(text: String) {
        headingLabel.attributedText = text.attributed(
            fontSize: 14,
            fontWeight: .regular,
            textColor: SeptaColor.black87,
            alignment: .left,
            kerning: 0.1,
            lineHeight: 24
        )
    }

    func setTimeOfDayLabelDate(date: Date, heading: String) {
        let text = DateFormatters.hourMinuteFormatter.string(from: date)
        setTimeOfDayLabel(text: text)
        setHeadingLabel(text: heading)
    }
}
