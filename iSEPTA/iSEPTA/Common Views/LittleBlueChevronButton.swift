//
//  LittleBlueChevron.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class LittleBlueChevronButton: UIControl {

    var buttonHighlighted = false

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawLittleBlueChevron(frame: rect, resizing: .center, buttonHighlighted: buttonHighlighted)
    }

    override func awakeFromNib() {
        layer.masksToBounds = false
    }

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)

        setNeedsDisplay()
        return true
    }

    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)

        setNeedsDisplay()
    }
}
