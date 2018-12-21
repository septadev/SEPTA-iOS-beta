//
//  NoFavoriteViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/15/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import UIKit

class NoFavoritesViewController: UIViewController, IdentifiableController {
    let viewController: ViewController = .noFavoritesViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = SeptaColor.navBarBlue
    }

    @IBOutlet var infoLabel: UILabel! {
        didSet {
            let attributedString = NSMutableAttributedString(string: SeptaString.NoFavoritesInfo)
            attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.bold), range: NSRange(location: 43, length: 16))
            infoLabel.attributedText = attributedString
        }
    }

    @IBAction func goToFavoritesTapped(_: Any) {
        let action = SwitchTabs(activeNavigationController: .nextToArrive, description: "Moving from No favorites to Next to arrive")
        store.dispatch(action)

        let resetViewState = ResetViewState(viewController: .nextToArriveController, description: "Navigating to Next to Arrive from No Favorites")
        store.dispatch(resetViewState)
    }

    @IBOutlet var iconStackView: UIStackView! {
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
