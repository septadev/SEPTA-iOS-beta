//
//  TransitAlertsViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/1/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import UIKit

class SeptaAlertsViewController: UIViewController {
    @IBOutlet var alertStackView: UIStackView!

    let alertsDict = store.state.alertState.alertDict
    var alertsCount: Int = 0
    var transitMode: TransitMode?
    var route: Route?

    public func setTransitMode(_ transitMode: TransitMode, route: Route) {
        self.transitMode = transitMode
        self.route = route
        if let alert = alertsDict[transitMode]?[route.routeId] {
            configureAlerts(alert: alert)
        } else {
            hasAlerts = false
            view.isHidden = true
        }
    }

    @IBAction func didTapAlertView(_: Any) {
        if alertsCount > 0 {
            let action = NavigateToAlertDetailsFromSchedules(scheduleState: store.state.scheduleState)
            store.dispatch(action)
        }
    }

    private func configureAlerts(alert: SeptaAlert) {
        let alertViewElements = alert.alertViewElements()
        alertsCount = alertViewElements.count
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
