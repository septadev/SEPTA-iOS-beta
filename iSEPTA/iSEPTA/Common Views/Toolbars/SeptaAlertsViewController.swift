//
//  TransitAlertsViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/1/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

class SeptaAlertsViewController: UIViewController {

    @IBOutlet weak var alertStackView: UIStackView!

    func displaySeptaAlert(alert: SeptaAlert) {
        if alert.advisory {

            let alertViewElements = alert.alertViewElements()
            for element in alertViewElements {
                let alertView = loadAlertView()
                alertView.alertIcon.image = element.image
                alertView.alertLabel.text = element.text
                alertStackView.addArrangedSubview(alertView)
            }
        }
    }

    func loadAlertView() -> TransitAlertView {
        let loadedNib = Bundle.main.loadNibNamed("TransitAlertView", owner: nil, options: nil) as! [TransitAlertView]
        let alertView: TransitAlertView = loadedNib[0]
        return alertView
    }
}
