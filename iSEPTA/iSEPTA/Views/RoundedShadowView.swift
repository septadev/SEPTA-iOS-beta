//
//  RoundedShadowView.swift
//  FavoritesCell
//
//  Created by Mark Broski on 9/14/17.
//  Copyright © 2017 SEPTA. All rights reserved.
//

import Foundation
import UIKit

class RoundedSurroundShadowedCellView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = false
    }

    override var bounds: CGRect {
        didSet {
            setupShadow()
        }
    }

    var layerCornerRadius: CGFloat = 4
    var shadowOffset = CGSize(width: 0, height: 0)
    var shadowOpacity: Float = 0.23

    private func setupShadow() {

        layer.shadowOffset = shadowOffset
        layer.shadowRadius = layerCornerRadius
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: layerCornerRadius, height: layerCornerRadius)).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
}
