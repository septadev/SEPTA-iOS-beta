//
//  AlertViewBackground.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/31/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable
class AlertViewGradientBackgroundView: UIView {

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawAlertView(alertViewFrame: rect)
    }
}
