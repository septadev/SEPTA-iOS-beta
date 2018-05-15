//
//  NextToArriveButton.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/2/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class NextToArriveButton: UIButton {
    override func draw(_ rect: CGRect) {
        SeptaDraw.drawNextToArriveButton(buttonFrame: rect, buttonHighlighted: isHighlighted)
    }

    private var shouldHighlight: Bool {
        return isHighlighted || !isEnabled
    }

    override func awakeFromNib() {
        layer.masksToBounds = false
    }

    override var isHighlighted: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
}
