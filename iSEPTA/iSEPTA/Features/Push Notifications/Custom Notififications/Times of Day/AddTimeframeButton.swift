//
//  AddTimeframeButton.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/31/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class AddTimeFrameButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        setTitleColor(SeptaColor.blue_20_75_136, for: .normal)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 25)
    }
}
