//
//  FavoriteCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class FavoriteTripCell: UITableViewCell {
    @IBOutlet weak var content: UIView!

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var favoriteIcon: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var favoriteNameLabel: UILabel!

    override func awakeFromNib() {

        styleClearViews([self, contentView])
        styleWhiteViews([shadowView, content])
    }

    func styleWhiteViews(_ views: [UIView]) {
        for view in views {
            view.backgroundColor = UIColor.white
            view.layer.cornerRadius = 4
        }
    }

    func styleClearViews(_ views: [UIView]) {
        for view in views {
            view.backgroundColor = UIColor.clear
        }
    }
}
