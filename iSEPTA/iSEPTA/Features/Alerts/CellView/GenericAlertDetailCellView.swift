//
//  AlertDetailCellView.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/5/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaRest
import UIKit

enum GenericAlertType {
    case genericAlert
    case appAlert
}

class GenericAlertDetailCellView: UIView, AlertState_GenericAlertDetailsWatcherDelegate,
    AlertState_AppAlertDetailsWatcherDelegate {
    private var openState: Bool = false

    var sectionNumber: Int!
    weak var delegate: AlertDetailCellDelegate?

    @IBOutlet var shadowView: UIView! {
        didSet {
            styleWhiteViews([shadowView])
            shadowView.layer.cornerRadius = 4
        }
    }

    var pinkAlertHeaderView: PinkAlertHeaderView!

    @IBOutlet var pinkWrapperView: UIView! {
        didSet {
            pinkAlertHeaderView = pinkWrapperView.awakeInsertAndPinSubview(nibName: "PinkAlertHeaderView")
            pinkAlertHeaderView.actionButton.addTarget(self, action: #selector(actionButtonTapped(_:)), for: .touchUpInside)
            pinkAlertHeaderView.enabled = true
        }
    }

    var genericAlertType: GenericAlertType = .genericAlert {
        didSet {
            switch genericAlertType {
            case .genericAlert: configureForGenericAlert()
            case .appAlert: configureForAppAlert()
            }
        }
    }

    func configureForGenericAlert() {
        pinkAlertHeaderView.advisoryLabel.text = "General Alert"
    }

    func configureForAppAlert() {
        pinkAlertHeaderView.advisoryLabel.text = "Mobile App Alert"
    }

    var alertImage: UIImageView { return pinkAlertHeaderView.alertImageView }

    var disabledAdvisoryLabel: UILabel { return pinkAlertHeaderView.disabledAdvisoryLabel }

    var advisoryLabel: UILabel { return pinkAlertHeaderView.advisoryLabel }

    var genericAlertDetailsWatcher: AlertState_GenericAlertDetailsWatcher?

    @IBOutlet var content: UIView! {
        didSet {
            styleWhiteViews([content])
            content.layer.cornerRadius = 4
            content.layer.masksToBounds = true
        }
    }

    var isGenericAlert: Bool = false {

        didSet {
            pinkAlertHeaderView.isGenericAlert = isGenericAlert

            textView.isScrollEnabled = isGenericAlert
            if isGenericAlert {
                genericAlertDetailsWatcher = AlertState_GenericAlertDetailsWatcher()
                genericAlertDetailsWatcher?.delegate = self
            }
        }
    }

    func alertState_GenericAlertDetailsUpdated(alertDetails: [AlertDetails_Alert]) {
        let message = AlertDetailsViewModel.renderMessage(alertDetails: alertDetails) { return $0.message }
        textView.attributedText = message
    }

    func alertState_AppAlertDetailsUpdated(alertDetails: [AlertDetails_Alert]) {
        let message = AlertDetailsViewModel.renderMessage(alertDetails: alertDetails) { return $0.message }
        textView.attributedText = message
    }

    @IBOutlet var textViewHeightContraints: NSLayoutConstraint! {
        didSet {
            textViewHeightContraints.constant = 0
        }
    }

    @IBOutlet var textView: UITextView!

    @objc @IBAction func actionButtonTapped(_: Any) {
        delegate?.didTapButton(sectionNumber: sectionNumber)
        toggleOpenState()
        delegate?.constraintsChanged(sectionNumber: sectionNumber)
    }

    func toggleOpenState() {

        if !openState {
            setOpenState()
        } else {
            setClosedState()
        }
    }

    private func setClosedState() {
        textViewHeightContraints.constant = 0
        pinkAlertHeaderView.actionButton.isOpen = false
        openState = false
        setNeedsLayout()
    }
    private func setOpenState() {
        let windowWidth = UIScreen.main.bounds.width - 30
        let sizeThatFitsTextView = textView.sizeThatFits(CGSize(width: windowWidth, height: CGFloat(MAXFLOAT)))
        let heightOfText = sizeThatFitsTextView.height

        textViewHeightContraints.constant = heightOfText
        pinkAlertHeaderView.actionButton.isOpen = true
        openState = true
        setNeedsLayout()
    }

    var fittingHeight: CGFloat {
        if pinkAlertHeaderView.actionButton.isOpen {
            let windowWidth = UIScreen.main.bounds.width - 50
            let sizeThatFitsTextView = textView.sizeThatFits(CGSize(width: windowWidth, height: CGFloat(MAXFLOAT)))
            let heightOfText = sizeThatFitsTextView.height
            return heightOfText + 75
        } else {
            return 75
        }
    }

    func setEnabled(_ enabled: Bool) {
        pinkAlertHeaderView.enabled = enabled
    }

    func initializeCellAsClosed() {
        setClosedState()
    }

    func styleWhiteViews(_ views: [UIView]) {
        for view in views {
            view.backgroundColor = UIColor.white
        }
    }

    func styleClearViews(_ views: [UIView]) {
        for view in views {
            view.backgroundColor = UIColor.clear
        }
    }
}
