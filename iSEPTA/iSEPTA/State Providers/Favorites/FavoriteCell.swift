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

    @IBOutlet weak var stackView: UIStackView!
    override func awakeFromNib() {

        backgroundColor = UIColor.green
        UIView.addSurroundShadow(toView: self, withCornerRadius: 4)
        separatorInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}
