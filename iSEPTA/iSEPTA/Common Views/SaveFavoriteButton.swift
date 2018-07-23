//
//  RedButton.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/15/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//
import UIKit

@IBDesignable
class SaveFavoriteButton: UIControl {
    var buttonHighlighted = false

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawSaveButton(frame: rect, enabled: isEnabled, buttonHighlighted: buttonHighlighted)
    }

    override var isEnabled: Bool {
        didSet {
            super.isEnabled = self.isEnabled
            setNeedsDisplay()
        }
    }

    override func awakeFromNib() {
        backgroundColor = UIColor.clear
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
