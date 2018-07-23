//
//  RedButton.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/15/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RedButton: UIControl {
    @IBInspectable
    var buttonTitle: String?
    var buttonHighlighted = false

    override func draw(_ rect: CGRect) {
        guard let buttonTitle = buttonTitle else { return }
        SeptaDraw.drawRedButton(frame: rect, redButtonText: buttonTitle, enabled: true, buttonHighlighted: buttonHighlighted)
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
