//
//  AlertDetailCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

protocol AlertDetailCellDelegate: AnyObject {
    func didTapButton(sectionNumber: Int)
}

class AlertDetailCell: UITableViewCell {
    var sectionNumber: Int!
    weak var delegate: AlertDetailCellDelegate?

    @IBOutlet weak var shadowView: AlertDetailCell!
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var disabledAdvisoryLabel: UILabel!
    @IBOutlet weak var advisoryLabel: UILabel!
    @IBOutlet weak var actionButton: AlertDetailButton!

    @IBOutlet weak var pinkHeaderView: PinkAlertHeaderView!
    @IBOutlet weak var textViewHeightContraints: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var alertImage: UIImageView!
    var openState: Bool = false

    @IBAction func actionButtonTapped(_: Any) {

        calculateFittingSize()
        delegate?.didTapButton(sectionNumber: sectionNumber)
    }

    func calculateFittingSize() {

        if !openState {
            let windowWidth = UIScreen.main.bounds.width - 50
            let sizeThatFitsTextView = textView.sizeThatFits(CGSize(width: windowWidth, height: CGFloat(MAXFLOAT)))
            let heightOfText = sizeThatFitsTextView.height

            textViewHeightContraints.constant = heightOfText
            actionButton.isOpen = true
            openState = true
        } else {
            textViewHeightContraints.constant = 0
            actionButton.isOpen = false
            openState = false
        }
        setNeedsLayout()
    }

    func setEnabled(_ enabled: Bool) {
        disabledAdvisoryLabel.isHidden = enabled
        advisoryLabel.isHidden = !enabled
        actionButton.isEnabled = enabled
        pinkHeaderView.enabled = enabled
    }

    override func awakeFromNib() {
        textViewHeightContraints.constant = 0
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
