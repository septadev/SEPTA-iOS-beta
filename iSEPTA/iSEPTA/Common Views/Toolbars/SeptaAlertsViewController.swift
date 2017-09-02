//
//  TransitAlertsViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/1/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import SeptaSchedule

class SeptaAlertsViewController: UIViewController {

    @IBOutlet weak var alertStackView: UIStackView!

    let alertsDict = store.state.alertState.alertDict

    public func setTransitMode(_ transitMode: TransitMode, route: Route) {
        if let alert = alertsDict[transitMode]?[route.routeId] {
            configureAlerts(alert: alert)
        } else {
            hasAlerts = false
            view.isHidden = true
        }
    }

    private func configureAlerts(alert: SeptaAlert) {
        let alertViewElements = alert.alertViewElements()
        for element in alertViewElements {
            let alertView = loadAlertView()
            alertView.alertIcon.image = element.image
            alertView.alertLabel.text = element.text
            alertStackView.addArrangedSubview(alertView)
        }

        hasAlerts = alertViewElements.count > 0
        view.isHidden = !hasAlerts
    }

    var hasAlerts: Bool = false

    private func loadAlertView() -> TransitAlertView {
        let loadedNib = Bundle.main.loadNibNamed("TransitAlertView", owner: nil, options: nil) as! [TransitAlertView]
        let alertView: TransitAlertView = loadedNib[0]
        return alertView
    }
}
