//
//  BigBlueChevron.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class BigBlueChevron: UIView {

    override var intrinsicContentSize: CGSize { return CGSize(width: 9, height: 18) }

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawBigBlueChevron(frame: rect, resizing: .center)
    }
}
