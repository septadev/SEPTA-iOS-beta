//
//  FavoriteTransitViewCell.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/25/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit

class FavoriteTransitViewCell: UITableViewCell {
    @IBOutlet var modeImage: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var shadowView: RoundedSurroundShadowedCellView!
    @IBOutlet var content: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

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
