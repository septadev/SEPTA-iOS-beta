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

    @IBOutlet var faresStackView: UIStackView!
    @IBAction func redButtonTapped(_: Any) {
    }

    @IBAction func moreAboutSeptaFaresTapped(_: Any) {
        let moreAction = MakeSeptaConnection(septaConnection: .fares)
        store.dispatch(moreAction)
    }

    @IBOutlet var moreAboutSEPTAFaresButton: UIView!

    @IBOutlet var faresWhiteInsetView: UIView!
    var faresViewModel: FaresViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
        faresViewModel = FaresViewModel()
        loadFaresStackView()
        UIView.addSurroundShadow(toView: faresWhiteInsetView, withCornerRadius: 0)
    }

    func loadFaresStackView() {
        for item in faresViewModel.items {
            guard let paymentView = Bundle.main.loadNibNamed("FarePaymentModeView", owner: nil, options: nil)?.first as? FarePaymentModeView else { continue }
            paymentView.icon.image = UIImage(named: item.imageName)
            paymentView.title.text = item.title
            paymentView.descriptionLabel.attributedText = item.description
            paymentView.septaConnection = item.septaConnection
            faresStackView.addArrangedSubview(paymentView)
        }
        faresStackView.addArrangedSubview(moreAboutSEPTAFaresButton)
    }
}
