//
//  DarkBlueGradient.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class DarkGradientBlueView: UIView {
    override func draw(_ rect: CGRect) {
        SeptaDraw.drawPerksBackground(frame: rect)
    }
}
