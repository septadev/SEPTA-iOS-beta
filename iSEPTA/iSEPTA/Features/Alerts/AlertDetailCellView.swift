//
//  AlertDetailCellView.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/5/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class AlertDetailCellView: UIView {

    var sectionNumber: Int!
    weak var delegate: AlertDetailCellDelegate?

    @IBOutlet weak var shadowView: UIView! {
        didSet {
            styleWhiteViews([shadowView])
        }
    }

    @IBOutlet var advisoryLabelLeft_GenericConstraint: NSLayoutConstraint!
    @IBOutlet var AdvisoryLabelLeft_NonGenericConstraint: NSLayoutConstraint!
    @IBOutlet weak var content: UIView! {
        didSet {
            styleWhiteViews([content])
        }
    }

    var isGenericAlert = false {
        didSet {
            if isGenericAlert {
                AdvisoryLabelLeft_NonGenericConstraint.isActive = false
                advisoryLabelLeft_GenericConstraint.isActive = true
                alertImage.isHidden = true
                advisoryLabel.text = "General Septa Alert"
                let alertDetails = store.state.alertState.genericAlertDetails
                let message = AlertDetailsViewModel.renderMessage(alertDetails: alertDetails) { return $0.advisory_message }
                textView.attributedText = message
                setEnabled(true)
            } else {
                advisoryLabelLeft_GenericConstraint.isActive = false
                AdvisoryLabelLeft_NonGenericConstraint.isActive = true
                alertImage.isHidden = false
            }
            setNeedsLayout()
        }
    }

    @IBOutlet weak var disabledAdvisoryLabel: UILabel!
    @IBOutlet weak var advisoryLabel: UILabel!
    @IBOutlet weak var actionButton: AlertDetailButton!

    @IBOutlet weak var pinkHeaderView: PinkAlertHeaderView!
    @IBOutlet weak var textViewHeightContraints: NSLayoutConstraint! {
        didSet {
            textViewHeightContraints.constant = 0
        }
    }

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var alertImage: UIImageView!

    var openState: Bool = false

    @IBAction func actionButtonTapped(_: Any) {
        delegate?.didTapButton(sectionNumber: sectionNumber)
        calculateFittingSize()
        delegate?.constraintsChanged(sectionNumber: sectionNumber)
    }

    func calculateFittingSize() {

        if !openState {
            let windowWidth = UIScreen.main.bounds.width - 30
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

    var fittingHeight: CGFloat {
        if actionButton.isOpen {
            let windowWidth = UIScreen.main.bounds.width - 50
            let sizeThatFitsTextView = textView.sizeThatFits(CGSize(width: windowWidth, height: CGFloat(MAXFLOAT)))
            let heightOfText = sizeThatFitsTextView.height
            return heightOfText + 75
        } else {
            return 75
        }
    }

    func setEnabled(_ enabled: Bool) {
        disabledAdvisoryLabel.isHidden = enabled
        advisoryLabel.isHidden = !enabled
        actionButton.isEnabled = enabled
        pinkHeaderView.enabled = enabled
        setNeedsLayout()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        advisoryLabelLeft_GenericConstraint.isActive = false
        AdvisoryLabelLeft_NonGenericConstraint.isActive = true
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
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
