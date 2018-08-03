//
//  UIResponder+Util.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/3/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

extension UIResponder {
    static func parentViewController(forView view: UIView) -> UIViewController? {
        var nextResponder: UIResponder? = view.next
        var result: UIViewController?

        while nextResponder != nil && result == nil {
            if let viewController = nextResponder as? UIViewController {
                result = viewController
            } else {
                nextResponder = nextResponder?.next
            }
        }

        return result
    }
}
