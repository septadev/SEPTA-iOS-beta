//
//  FaresViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/28/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class FaresViewController: UIViewController, IdentifiableController {
    var viewController: ViewController = .faresViewController
    var urlManager = SeptaWebUrlManager.sharedInstance
    @IBOutlet weak var faresStackView: UIStackView!
    @IBAction func redButtonTapped(_: Any) {
    }

    @IBAction func moreAboutSeptaFaresTapped(_: Any) {
        if let info = urlManager.info(forPage: .fares) {
            let moreAction = DisplayURL(septaUrlInfo: info)
            store.dispatch(moreAction)
            let pushAction = PushViewController(viewController: .webViewController, description: "Showing Fares Web View")
            store.dispatch(pushAction)
        }
    }

    @IBOutlet var moreAboutSEPTAFaresButton: UIView!

    @IBOutlet weak var faresWhiteInsetView: UIView!
    @IBOutlet weak var passPerksInsetView: UIView!
    var faresViewModel: FaresViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
        faresViewModel = FaresViewModel()
        loadFaresStackView()
        UIView.addSurroundShadow(toView: faresWhiteInsetView, withCornerRadius: 0)
        UIView.addSurroundShadow(toView: passPerksInsetView, withCornerRadius: 0)
    }

    @IBAction func moreAboutPassPerksTapped(_: Any) {
        guard let septaUrlInfo = urlManager.info(forPage: .passPerks) else { return }
        let moreAction = DisplayURL(septaUrlInfo: septaUrlInfo)
        store.dispatch(moreAction)
        let pushAction = PushViewController(viewController: .webViewController, description: "Showing Fares Web View")
        store.dispatch(pushAction)
    }

    func loadFaresStackView() {
        for item in faresViewModel.items {

            guard let paymentView = Bundle.main.loadNibNamed("FarePaymentModeView", owner: nil, options: nil)?.first as? FarePaymentModeView else { continue }
            paymentView.icon.image = UIImage(named: item.imageName)
            paymentView.title.text = item.title
            paymentView.descriptionLabel.attributedText = item.description
            paymentView.septaUrlInfo = item.septaUrlInfo
            faresStackView.addArrangedSubview(paymentView)
        }
        faresStackView.addArrangedSubview(moreAboutSEPTAFaresButton)
    }
}
