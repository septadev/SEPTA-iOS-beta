//
//  PinkAlertHeaderView.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class PinkAlertHeaderView: UIView {
    @IBInspectable
    @IBOutlet weak var disabledAdvisoryLabel: UILabel!
    @IBOutlet weak var advisoryLabel: UILabel!
    @IBOutlet weak var alertImageView: UIImageView!

    @IBOutlet weak var advisoryLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionButton: AlertDetailButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var isGenericAlert: Bool! {
        didSet {
            if isGenericAlert {
                advisoryLabelLeftConstraint.constant = 15
                alertImageView.isHidden = true
                advisoryLabel.text = "General Septa Alert"

                enabled = true
            } else {
                advisoryLabelLeftConstraint.constant = 54

                alertImageView.isHidden = false
            }
            setNeedsLayout()
        }
    }

    var enabled = true {
        didSet {
            disabledAdvisoryLabel.isHidden = enabled
            advisoryLabel.isHidden = !enabled
            actionButton.isEnabled = enabled
            setNeedsLayout()
        }
    }

    override func draw(_ rect: CGRect) {
        SeptaDraw.drawPinkAlertCellHeader(frame: rect, enabled: enabled)
    }
}
