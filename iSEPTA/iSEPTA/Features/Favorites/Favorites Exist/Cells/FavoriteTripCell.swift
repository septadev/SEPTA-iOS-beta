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
    @IBOutlet weak var viewSchedules: UILabel!
    @IBOutlet weak var titleLabelTrailing: NSLayoutConstraint!
    
    var delegate: FavoriteTripCellDelegate?
    var hasNtaData: Bool = true
    
    var currentFavorite: Favorite? {
        didSet {
            if let fav = currentFavorite {
                if fav.collapsed {
                    chevron.image = UIImage(named: "arrow-down")
                } else {
                    chevron.image = UIImage(named: "arrow-up")
                }
            }
        }
    }

    override func awakeFromNib() {
        styleClearViews([self, contentView])
        styleWhiteViews([shadowView, content])
        chevron.isHidden = !hasNtaData
        viewSchedules.isHidden = hasNtaData
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
        if hasNtaData {
            self.delegate?.favoriteCellToggled(cell: self)
        } else {
            let action = SwitchTabs(activeNavigationController: .schedules, description: "Jump to Schedules from favorite")
            store.dispatch(action)
        }
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
    
    func configureForShowSchedule() {
        hasNtaData = false
        chevron.isHidden = !hasNtaData
        viewSchedules.isHidden = hasNtaData
        titleLabelTrailing.constant = viewSchedules.frame.size.width - 10
    }
}

protocol FavoriteTripCellDelegate {
    func favoriteCellToggled(cell: FavoriteTripCell)
}
