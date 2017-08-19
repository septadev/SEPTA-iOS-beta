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
}
