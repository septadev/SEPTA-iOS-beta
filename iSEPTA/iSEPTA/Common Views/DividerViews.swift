//
//  DividerViewLeft.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

import UIKit

@IBDesignable
class BentDividerViewLeft: UIView {
    override func awakeFromNib() {
        backgroundColor = UIColor.clear
    }

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawConnectingBentDividerViewLeft(frame: rect)
    }
}

@IBDesignable
class BentDividerViewRight: UIView {
    override func awakeFromNib() {
        backgroundColor = UIColor.clear
    }

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawConnectingBentDividerViewRight(frame: rect)
    }
}

@IBDesignable
class FlatDividerView: UIView {
    override func awakeFromNib() {
        backgroundColor = UIColor.clear
    }

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawConnectingFlatDividerView(frame: rect)
    }
}
