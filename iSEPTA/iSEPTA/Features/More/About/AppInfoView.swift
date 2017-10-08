//
//  AppInfoView.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class AppInfoView: UIView {
    @IBOutlet private weak var keyLabel: UILabel!

    @IBOutlet private weak var valueLabel: UILabel!

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 25)
    }

    func setKeyText(_ text: String) {
        keyLabel.text = text
    }

    func setValueText(_ text: String) {
        valueLabel.text = text
    }
}
