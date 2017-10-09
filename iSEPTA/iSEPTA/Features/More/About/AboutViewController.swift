//
//  AboutViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController, IdentifiableController, UITextViewDelegate {
    var viewController: ViewController = .aboutViewController
    var openState: Bool = false
    @IBOutlet weak var attributionsView: UIView!
    @IBOutlet weak var attributionsLabel: UILabel!
    @IBOutlet weak var appInformationView: UIView!
    @IBOutlet weak var appInfoStackView: UIStackView!

    @IBOutlet weak var plusButton: AlertDetailButton!

    @IBOutlet weak var licenseTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var licenseTextView: UITextView! {
        didSet {
            licenseTextView.delegate = self
        }
    }

    @IBOutlet weak var attributionsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attributionsTextView: UITextView! {
        didSet {
            attributionsTextView.delegate = self
        }
    }

    var viewModel: AboutViewModel!

    @IBAction func redButtonTapped(_: Any) {
        let action = MakeSeptaConnection(septaConnection: .comment)
        store.dispatch(action)
    }

    override func viewDidLoad() {
        view.backgroundColor = SeptaColor.navBarBlue

        super.viewDidLoad()
        viewModel = AboutViewModel()
        buildAppInfo()
        UIView.addSurroundShadow(toView: appInformationView, withCornerRadius: 3)
        UIView.addSurroundShadow(toView: attributionsView, withCornerRadius: 3)
        attributionsHeightConstraint.constant = 0
        setLicenseHeight()
    }

    func setLicenseHeight() {
        let windowWidth = UIScreen.main.bounds.width - 30
        let sizeThatFitsTextView = licenseTextView.sizeThatFits(CGSize(width: windowWidth, height: CGFloat(MAXFLOAT)))
        licenseTextViewHeightConstraint.constant = sizeThatFitsTextView.height
    }

    func buildAppInfo() {
        for viewItem in viewModel.viewItems {
            guard let appInfoView: AppInfoView = UIView.loadNibView(nibName: "AppInfoView") else { return }
            appInfoView.setKeyText(viewItem.title)
            appInfoView.setValueText(viewItem.value)
            appInfoStackView.addArrangedSubview(appInfoView)
        }
    }

    @IBAction func openButtonTapped(_: Any) {
        openState = !openState

        calculateFittingSize()
    }

    func calculateFittingSize() {
        guard let view = self.view else { return }
        let newTitleText: String
        if openState {
            let windowWidth = UIScreen.main.bounds.width - 60
            let sizeThatFitsTextView = attributionsTextView.sizeThatFits(CGSize(width: windowWidth, height: CGFloat(MAXFLOAT)))
            let heightOfText = sizeThatFitsTextView.height

            attributionsHeightConstraint.constant = heightOfText
            newTitleText = "Hide Attributions"

        } else {
            attributionsHeightConstraint.constant = 0
            newTitleText = "View Attributions"
        }
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.25, animations: { view.layoutIfNeeded() }, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.attributionsLabel.text = newTitleText
            strongSelf.plusButton.isOpen = strongSelf.openState
        })
    }

    func textView(_: UITextView, shouldInteractWith URL: URL, in _: NSRange) -> Bool {

        return true
    }

    //
    //    var fittingHeight: CGFloat {
    //        if pinkAlertHeaderView.actionButton.isOpen {
    //            let windowWidth = UIScreen.main.bounds.width - 50
    //            let sizeThatFitsTextView = textView.sizeThatFits(CGSize(width: windowWidth, height: CGFloat(MAXFLOAT)))
    //            let heightOfText = sizeThatFitsTextView.height
    //            return heightOfText + 75
    //        } else {
    //            return 75
    //        }
    //    }
}
