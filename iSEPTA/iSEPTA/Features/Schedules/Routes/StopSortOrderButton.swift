//
//  StopSortOrderButton.swift
//  iSEPTA
//
//  Created by Mike Mannix on 6/26/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit

@IBDesignable
class StopSortOrderButton: UIView {
    var active = false {
        didSet {
            self.layer.borderColor = SeptaColor.stopOrderButtonBlue.cgColor
            self.backgroundColor = active ? SeptaColor.stopOrderButtonBlue : .clear
        }
    }

    let buttonImage = UIImageView()
    var order: SortOrder = .alphaAscending

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        buttonImage.image = UIImage(named: "clipboardIcon")
        buttonImage.contentMode = .center

        addImageViewToButtonImage()

        layer.borderWidth = 1.2
        active = false
    }

    private func addImageViewToButtonImage() {
        addSubview(buttonImage)
        buttonImage.translatesAutoresizingMaskIntoConstraints = false
        let x = NSLayoutConstraint(item: buttonImage, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let y = NSLayoutConstraint(item: buttonImage, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let w = NSLayoutConstraint(item: buttonImage, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        let h = NSLayoutConstraint(item: buttonImage, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
        addConstraints([x, y, w, h])
    }
}

public enum SortOrder: String {
    case alphaAscending
    case alphaDescending
    case stopSequence
}
