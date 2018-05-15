//
//  BlueGradientBackgroundView.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/19/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class BlueGradientBackgroundView: UIView {

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawBlueGradientView(frame: rect)
    }
}
