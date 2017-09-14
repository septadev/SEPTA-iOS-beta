//
//  UIStackView+Util.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

extension UIStackView {
    func addAlert(_ alert: SeptaAlert?) {
        spacing = 2.0
        distribution = .fill
        alignment = .center
        for subview in arrangedSubviews {
            removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
        if let alert = alert {
            let imageViews = alert.imagesForAlert().map {
                UIImageView(image: $0)
            }
            for imageView in imageViews {
                imageView.isUserInteractionEnabled = true
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                let height = NSLayoutConstraint(item: imageView,
                                                attribute: .height,
                                                relatedBy: .equal,
                                                toItem: nil,
                                                attribute: .notAnAttribute,
                                                multiplier: 1.0,
                                                constant: 18)
                let width = NSLayoutConstraint(item: imageView,
                                               attribute: .width,
                                               relatedBy: .equal,
                                               toItem: nil,
                                               attribute: .notAnAttribute,
                                               multiplier: 1.0,
                                               constant: 18)
                imageView.addConstraints([height, width])
                addArrangedSubview(imageView)
            }
        }
    }

    func clearSubviews() {
        for subview in arrangedSubviews {
            removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }
}
