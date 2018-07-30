//
//  PerksViewController.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/30/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import UIKit

class PerksViewController: UIViewController, IdentifiableController {
    var viewController: ViewController = .perksViewController

    @IBOutlet var passPerksInsetView: UIView!
    @IBOutlet var learnMoreButton: RedButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = SeptaColor.navBarBlue
        UIView.addSurroundShadow(toView: passPerksInsetView, withCornerRadius: 0)
        learnMoreButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(learnMoreTapped(_:))))
    }

    @objc func learnMoreTapped(_: UITapGestureRecognizer) {
        let moreAction = MakeSeptaConnection(septaConnection: .passPerks)
        store.dispatch(moreAction)
    }
}
