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
class CurvedTopInfoView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = false
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        SeptaDraw.drawCurvedTopView(frame: rect)
    }
}
