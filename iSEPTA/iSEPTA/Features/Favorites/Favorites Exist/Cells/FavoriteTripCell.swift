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
    @IBOutlet var content: UIView!

    @IBOutlet var shadowView: UIView!
    @IBOutlet var favoriteIcon: UIImageView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var favoriteNameLabel: UILabel!

    @IBOutlet var headerAccessibilityElements: [UIView]!
    var currentFavorite: Favorite?

    override func awakeFromNib() {

        styleClearViews([self, contentView])
        styleWhiteViews([shadowView, content])
    }

    @IBAction func moreButtonTapped(_: Any) {
        guard let currentFavorite = currentFavorite else { return }

        let dataAction = CreateNextToArriveFavorite(favorite: currentFavorite)
        store.dispatch(dataAction)

        let navigationAction = PushViewController(viewController: .nextToArriveDetailController, description: "Displaying Next to arrive for a favorite")
        store.dispatch(navigationAction)
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
