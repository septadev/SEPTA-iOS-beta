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
    @IBOutlet var attributionsView: UIView!
    @IBOutlet var attributionsLabel: UILabel!
    @IBOutlet var appInformationView: UIView!
    @IBOutlet var appInfoStackView: UIStackView!
    @IBOutlet weak var septaLogoImage: UIImageView!
    
    @IBOutlet var plusButton: AlertDetailButton!

    @IBOutlet var licenseTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var licenseTextView: UITextView! {
        didSet {
            licenseTextView.delegate = self
        }
    }

    @IBOutlet var attributionsHeightConstraint: NSLayoutConstraint!
    @IBOutlet var attributionsTextView: UITextView! {
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
        appBuildConfigInfo()
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

    // MARK: - Debug Easter Egg - Add touch to Septa Logo
    func appBuildConfigInfo() {
        let dictionary = Bundle.main.infoDictionary!
        let bundleID = dictionary["CFBundleIdentifier"] as! String
        if bundleID.contains("beta") {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTouchSeptaLogo(tapGestureRecognizer:)))
            septaLogoImage.isUserInteractionEnabled = true
            septaLogoImage.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    // Resets alert don't show flags
    @objc func didTouchSeptaLogo(tapGestureRecognizer: UITapGestureRecognizer) {
        let action = DoNotShowThisAlertAgain(lastSavedDoNotShowThisAlertAgainState: "", doNotShowThisAlertAgain: false)
        store.dispatch(action)
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
