//
//  BlueGradientHeader.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class BlueGradientTitleView: UIView {
    override func draw(_ rect: CGRect) {
        SeptaDraw.drawBlueGradientTitleView(frame: rect)
    }
}
