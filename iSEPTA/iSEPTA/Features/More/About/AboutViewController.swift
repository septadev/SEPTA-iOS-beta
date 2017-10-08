//
//  AboutViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class AboutViewController: UIViewController, IdentifiableController {
    var viewController: ViewController = .aboutViewController

    @IBOutlet weak var appInformationView: UIView!
    @IBOutlet weak var appInfoStackView: UIStackView!

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
    }

    func buildAppInfo() {
        for viewItem in viewModel.viewItems {
            guard let appInfoView: AppInfoView = UIView.loadNibView(nibName: "AppInfoView") else { return }
            appInfoView.setKeyText(viewItem.title)
            appInfoView.setValueText(viewItem.value)
            appInfoStackView.addArrangedSubview(appInfoView)
        }
    }
}
