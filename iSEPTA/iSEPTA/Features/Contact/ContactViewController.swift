//
//  ContactViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class ContactViewController: UIViewController, IdentifiableController {
    var viewController: ViewController = .contactViewController

    @IBOutlet weak var customerServiceStackView: UIStackView!

    @IBOutlet weak var socialMediaInsetView: UIView!
    @IBOutlet weak var customerServiceInsetView: UIView!
    @IBOutlet weak var socialMediaStackView: UIStackView!
    var viewModel: ContactViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
        viewModel = ContactViewModel()

        addShadows()
        setUpContent()
    }

    func setUpContent() {
        configureStackView(customerServiceStackView, withContactPoints: viewModel.customerServiceOptions())
        configureStackView(socialMediaStackView, withContactPoints: viewModel.customerSocialMediaOptions())
    }

    func addShadows() {
        UIView.addSurroundShadow(toView: customerServiceInsetView, withCornerRadius: 0)
        UIView.addSurroundShadow(toView: socialMediaInsetView, withCornerRadius: 0)
    }

    func configureStackView(_ stackView: UIStackView, withContactPoints contactPoints: [ContactPoint]) {
        for contactPoint in contactPoints {

            guard let customerServiceControl = Bundle.main.loadNibNamed("CustomerServiceControl", owner: nil, options: nil)?.first as? CustomerServiceControl else { return }
            customerServiceControl.displayContactPoint(contactPoint)
            stackView.addArrangedSubview(customerServiceControl)
        }
    }
}
