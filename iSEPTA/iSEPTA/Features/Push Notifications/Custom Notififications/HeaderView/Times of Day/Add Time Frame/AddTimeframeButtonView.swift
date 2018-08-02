//
//  AddTimeframeButtonView.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/31/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class AddTimeframeButtonView: UIView {
    @IBOutlet var divider: UIView! {
        didSet {
            divider.backgroundColor = SeptaColor.gray_198
        }
    }

    @IBOutlet var addTimeFrameButton: UIButton!

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 65)
    }
}
