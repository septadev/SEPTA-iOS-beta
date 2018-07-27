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
    @IBOutlet var alertsStackView: UIStackView! {
        didSet {
            alertsStackView.isExclusiveTouch = true
        }
    }

    var favorite: Favorite?

    override func awakeFromNib() {
        super.awakeFromNib()

        styleClearViews([self, contentView])
        styleWhiteViews([shadowView, content])

        content.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToTransitView(_:))))
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

    func addAlert(_ alert: SeptaAlert?) {
        alertsStackView.addAlert(alert)
    }

    @objc func goToTransitView(_: Any) {
        guard let favorite = favorite else { return }
        let selectedAction = TransitViewFavoriteSelected(favorite: favorite, description: "TransitView favorite was selected")
        store.dispatch(selectedAction)
        let pushAction = PushViewController(viewController: .transitViewMap, description: "Displaying TransitView for a favorite")
        store.dispatch(pushAction)
    }
}
