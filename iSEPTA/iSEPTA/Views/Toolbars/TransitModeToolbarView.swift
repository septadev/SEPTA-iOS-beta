//
//  TransitModeToolbarView.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/6/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class TransitModeToolbarView: UIView {

    @IBInspectable var highlighted: Bool = false
    @IBInspectable var title: String = "TransitMode"
    @IBInspectable var id: String = "bus"
    var transitMode: TransitMode? { return TransitMode(rawValue: id) }

    override func draw(_ rect: CGRect) {
        backgroundColor = nil
        SeptaDraw.drawTranssitModeToolbar(frame: rect, transitMode: title, highlighted: highlighted)
    }
}
