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
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var chevron: UIImageView!
    @IBOutlet var headerAccessibilityElements: [UIView]!
    
    var delegate: FavoriteTripCellDelegate?
    
    var currentFavorite: Favorite? {
        didSet {
            if let fav = currentFavorite {
                if fav.collapsed {
                    chevron.image = UIImage(named: "chevronRight")
                } else {
                    chevron.image = UIImage(named: "chevronDown")
                }
            }
        }
    }

    override func awakeFromNib() {
        styleClearViews([self, contentView])
        styleWhiteViews([shadowView, content])
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headerTapped(sender:))))
        stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showNextToArrive(_:))))
    }

    @objc func showNextToArrive(_: Any) {
        guard let currentFavorite = currentFavorite else { return }

        let dataAction = CreateNextToArriveFavorite(favorite: currentFavorite)
        store.dispatch(dataAction)

        let navigationAction = PushViewController(viewController: .nextToArriveDetailController, description: "Displaying Next to arrive for a favorite")
        store.dispatch(navigationAction)
    }
    
    @objc func headerTapped(sender: UITapGestureRecognizer) {
        self.delegate?.favoriteCellToggled(cell: self)
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

protocol FavoriteTripCellDelegate {
    func favoriteCellToggled(cell: FavoriteTripCell)
}
