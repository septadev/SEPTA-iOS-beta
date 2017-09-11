//
//  UIView+Util.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/19/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

extension UIView {

    class func instanceFromNib<T>(named name: String) -> T {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! T
    }

    class func addSurroundShadow(toView view: UIView, withCornerRadius radius: CGFloat = 9) {
        let layer = view.layer
        layer.cornerRadius = radius

        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 4
        layer.shadowOpacity = 1
        layer.shadowColor = SeptaColor.viewShadowColor.cgColor

        layer.masksToBounds = false
    }

    func addStandardDropShadow() {
        let layer = self.layer
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3.0)
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.41
        layer.masksToBounds = false
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}
