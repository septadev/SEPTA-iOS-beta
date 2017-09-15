//
//  NoFavoriteViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/15/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import SeptaSchedule

class NoFavoritesViewController: UIViewController {

    @IBOutlet weak var shadowView: UIView! {
        didSet {
            shadowView.backgroundColor = SeptaColor.navBarBlue
            shadowView.layer.masksToBounds = false
            shadowView.layer.shadowOffset = CGSize(width: 0, height: 0.0)
            shadowView.layer.shadowRadius = 7
            shadowView.layer.shadowOpacity = 1
            shadowView.layer.shadowColor = SeptaColor.navBarShadowColor.cgColor
        }
    }

    @IBOutlet weak var iconStackView: UIStackView! {
        didSet {
            for transitMode in TransitMode.displayOrder() {
                guard let noTransitModeView: NoFavoriteTransitModeView = UIView.loadNibView(nibName: "NoFavoriteTransitModeView") else { return }
                noTransitModeView.transitMode = transitMode
                noTransitModeView.invalidateIntrinsicContentSize()
                iconStackView.addArrangedSubview(noTransitModeView)
                noTransitModeView.invalidateIntrinsicContentSize()
            }
        }
    }
}
