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
class BackButton: UIControl {

    @IBInspectable

    var buttonHighlighted = false

    override func draw(_ rect: CGRect) {
        backgroundColor = SeptaColor.navBarBlue
        SeptaDraw.drawNavBarBackButton(frame: rect)
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

class BackButtonBarItem: UIBarButtonItem {
    override func awakeAfter(using _: NSCoder) -> Any? {
        return UIBarButtonItem(customView: BackButton(frame: CGRect(x: 0, y: 0, width: 13, height: 21)))
    }
}
