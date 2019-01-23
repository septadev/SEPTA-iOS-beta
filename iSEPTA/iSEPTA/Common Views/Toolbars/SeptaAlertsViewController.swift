//
//  TransitAlertsViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/1/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule
import UIKit

class SeptaAlertsViewController: UIViewController, StoreSubscriber {
    typealias StoreSubscriberStateType = SeptaAlert?
    @IBOutlet var alertStackView: UIStackView!

    let alertsDict = store.state.alertState.alertDict
    var alertsCount: Int = 0
    var transitMode: TransitMode?
    var route: Route?
    @IBOutlet var statusAlertLabel: UILabel! {
        didSet {
            guard let text = statusAlertLabel.text else { return }
            statusAlertLabel.attributedText = text.attributed(
                fontSize: 12,
                fontWeight: .bold,
                textColor: UIColor.black,
                alignment: .left,
                kerning: -0.2
            )
        }
    }

    @IBOutlet var subscribeLabel: UILabel! {
        didSet {
            guard let text = subscribeLabel.text else { return }
            subscribeLabel.attributedText = text.attributed(
                fontSize: 10,
                fontWeight: .regular,
                textColor: SeptaColor.gray_109,
                alignment: .left
            )
        }
    }

    @IBOutlet var dividers: [UIView]! {
        didSet {
            _ = dividers.map { $0.backgroundColor = SeptaColor.gray_135 }
        }
    }

    var pushNotificationSubsciber: PushNotificationSubscriber?
    @IBOutlet var pushNotificationSwitch: UISwitch! {
        didSet {
            guard let transitMode = transitMode, let route = route else { return }
            pushNotificationSubsciber = PushNotificationSubscriber(transitMode: transitMode, route: route, uiSwitch: pushNotificationSwitch, viewController: self)
        }
    }

    @IBOutlet var constraintsForWidePhone: [NSLayoutConstraint]!

    @IBOutlet var contraintsForNarrowPhone: [NSLayoutConstraint]!

    public func setTransitMode(_ transitMode: TransitMode, route: Route) {
        self.transitMode = transitMode
        self.route = route
        let alert = alertsDict[transitMode]?[route.routeId]
        configureAlerts(alert: alert)

        guard let uiSwitch = pushNotificationSwitch else { return }

        let routeIsGC = route.routeId == "GC"
        uiSwitch.isHidden = routeIsGC
        subscribeLabel.isHidden = routeIsGC

        pushNotificationSubsciber = PushNotificationSubscriber(transitMode: transitMode, route: route, uiSwitch: uiSwitch, viewController: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureConstraints()
    }

    func configureConstraints() {
    }

    @IBOutlet var advisoryImageView: UIImageView!
    @IBOutlet var alertImageView: UIImageView!

    @IBOutlet var detourImageView: UIImageView!

    @IBOutlet var weatherImageView: UIImageView!

    @IBAction func didTapAlertView(_: Any) {
        let action = NavigateToAlertDetailsFromSchedules(scheduleState: store.state.scheduleState)
        store.dispatch(action)
    }

    func newState(state: StoreSubscriberStateType) {
        configureAlerts(alert: state)
    }

    private func configureAlerts(alert: SeptaAlert?) {
        guard let alert = alert else { return }
        advisoryImageView.isHighlighted = alert.advisory
        alertImageView.isHighlighted = alert.alert
        if !alert.alert && !alert.suspended {
            alertImageView.image = UIImage(named: "suspendedAlert")
        }
        detourImageView.isHighlighted = alert.detour
        weatherImageView.isHighlighted = alert.weather
    }

    func subscribe(transitMode: TransitMode, route: Route) {
        store.subscribe(self) {
            $0.select { $0.alertState.alertDict[transitMode]?[route.routeId] }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }

    class PushNotificationSubscriber: StoreSubscriber {
        typealias StoreSubscriberStateType = PushNotificationRoute?

        let pushNotificationRoute: PushNotificationRoute
        let uiSwitch: UISwitch
        weak var viewController: UIViewController?

        init(transitMode: TransitMode, route: Route, uiSwitch: UISwitch, viewController: UIViewController) {
            pushNotificationRoute = PushNotificationRoute(routeId: route.routeId, routeName: route.routeShortName, transitMode: transitMode)
            self.uiSwitch = uiSwitch
            self.viewController = viewController
            subscribe(routeId: route.routeId)

            uiSwitch.addTarget(self, action: #selector(pushNotificationValueChanged(sender:)), for: .valueChanged)
        }

        func subscribe(routeId: String) {
            store.subscribe(self) {
                $0.select { $0.preferenceState.pushNotificationPreferenceState.routeIds.first(where: { $0.routeId == routeId }) }
            }
        }

        @IBAction func pushNotificationValueChanged(sender: UISwitch) {
            guard let viewController = viewController else { return }
            DispatchQueue.main.async {
                var route = self.pushNotificationRoute
                route.isEnabled = sender.isOn
                store.dispatch(UpdatePushNotificationRoute(route: route, postImmediately: true, viewController: viewController))
            }
        }

        @IBAction func toggleNotificationsValueChanged(_: UISwitch) {
        }

        func newState(state: PushNotificationRoute?) {
            uiSwitch.isOn = state?.isEnabled ?? false
        }
    }
}
