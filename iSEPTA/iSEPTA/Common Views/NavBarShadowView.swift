//
//  NavBarShadowView.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/15/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class NavBarShadowView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = SeptaColor.navBarBlue
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 0, height: 0.0)
        layer.shadowRadius = 7
        layer.shadowOpacity = 1
        layer.shadowColor = SeptaColor.navBarShadowColor.cgColor
    }
}
