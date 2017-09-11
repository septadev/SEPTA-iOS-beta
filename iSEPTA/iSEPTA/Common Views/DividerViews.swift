//
//  DividerViewLeft.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

import UIKit

class BentDividerViewLeft: UIView {

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawConnectingBentDividerViewLeft(frame: rect)
    }
}

class BentDividerViewRight: UIView {

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawConnectingBentDividerViewRight(frame: rect)
    }
}

class FlatDividerView: UIView {

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawConnectingFlatDividerView(frame: rect)
    }
}
