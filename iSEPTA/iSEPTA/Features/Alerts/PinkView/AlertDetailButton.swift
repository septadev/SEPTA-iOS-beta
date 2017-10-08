//
//  AlertButton.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class AlertDetailButton: UIControl {
    var buttonHighlighted = false
    var isOpen: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawAlertButton(frame: rect, resizing: .center, enabled: isEnabled, buttonHighlighted: buttonHighlighted, isOpen: isOpen)
    }

    override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            setNeedsDisplay()
        }
    }

    override func awakeFromNib() {
        layer.masksToBounds = false
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        buttonHighlighted = true
        setNeedsDisplay()
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        buttonHighlighted = false
        setNeedsDisplay()
    }
}
