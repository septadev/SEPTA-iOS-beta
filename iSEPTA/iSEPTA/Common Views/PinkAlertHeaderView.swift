//
//  PinkAlertHeaderView.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class PinkAlertHeaderView: UIView {
    @IBInspectable
    var enabled = true {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawPinkAlertCellHeader(frame: rect, enabled: enabled)
    }
}
