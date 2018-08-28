//
//  ConnectGradientView.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/1/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class ConnectGradientView: UIView {
    override func draw(_ rect: CGRect) {
        SeptaDraw.drawConnectGradientView(frame: rect)
    }
}
