//
//  SelectStopSearchView.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/25/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CurvedTopView: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let rectanglePath = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 14, height: 14))
        rectanglePath.close()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = rectanglePath.cgPath
        layer.mask = shapeLayer
        layer.masksToBounds = true
    }
}
