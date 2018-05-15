//
//  NextToArriveButtonView.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/1/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ReverseTripButton: UIButton {
    override func draw(_ rect: CGRect) {
        SeptaDraw.drawReverseTripButton(frame: rect, resizing: .center, buttonHighlighted: shouldHighlight)
    }

    private var shouldHighlight: Bool {
        return isHighlighted || !isEnabled
    }

    override var isHighlighted: Bool {
        didSet {
            setNeedsDisplay()
        }
    }
}
