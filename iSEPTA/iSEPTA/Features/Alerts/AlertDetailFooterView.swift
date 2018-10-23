//
//  AlertDetailFooterView.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/1/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule
import UIKit

class AlertDetailFooterView: UIView, StoreSubscriber {
    typealias StoreSubscriberStateType = [PushNotificationRoute]

    var pushNotificationRoute: PushNotificationRoute? {
        didSet {
            // Glendale Combined is "unsubscribable"
            isHidden = pushNotificationRoute?.routeId == "GC"
            store.subscribe(self) {
                $0.select { $0.preferenceState.pushNotificationPreferenceState.routeIds }
            }
        }
    }

    @IBAction func toggleNotificationsValueChanged(_ sender: UISwitch) {
        guard var route = pushNotificationRoute else { return }
        guard let viewController = UIResponder.parentViewController(forView: self) else { return }
        DispatchQueue.main.async {
            route.isEnabled = sender.isOn
            store.dispatch(UpdatePushNotificationRoute(route: route, postImmediately: true, viewController: viewController))
        }
    }

    @IBAction func userTappedOnViewNotificationPreferences(_: Any) {
        store.dispatch(SwitchTabs(activeNavigationController: .more, description: "User wants to view preferences"))
        let action = ResetViewState(viewController: .managePushNotficationsController, description: "Navigating to Push Notifications from Alerts")
        store.dispatch(action)
    }

    func newState(state: StoreSubscriberStateType) {
        guard let route = pushNotificationRoute else { return }
        if let routeIndex = state.indexOfRoute(route: route) {
            let route = state[routeIndex]
            pushNotificationToggleView.isOn = route.isEnabled
        } else {
            pushNotificationToggleView.isOn = false
        }
    }

    deinit {
        store.unsubscribe(self)
    }

    @IBOutlet var pushNotificationToggleView: UISwitch!

    @IBOutlet var subscribeLabel: UILabel! {
        didSet {
            guard let text = subscribeLabel.text else { return }
            subscribeLabel.attributedText = text.attributed(
                fontSize: 14,
                fontWeight: .bold
            )
            subscribeLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 93
            subscribeLabel.setNeedsLayout()
        }
    }

    @IBOutlet var dividerLabel: UIView! {
        didSet {
            dividerLabel.backgroundColor = SeptaColor.gray_135
        }
    }

    @IBOutlet var viewPreferencesButton: UIButton! {
        didSet {
            guard let text = viewPreferencesButton.titleLabel?.text else { return }
            let attributedText = text.attributed(
                fontSize: 12,
                fontWeight: .regular,
                textColor: SeptaColor.blue_20_75_136,
                alignment: .left,
                kerning: 0.2,
                lineHeight: nil
            )
            viewPreferencesButton.setAttributedTitle(attributedText, for: .normal)
        }
    }

    @IBOutlet var viewPreferencesLabel: UILabel! {
        didSet {
            guard let text = viewPreferencesLabel.text else { return }
            viewPreferencesLabel.attributedText = text.attributed(
                fontSize: 12,
                fontWeight: .bold,
                textColor: SeptaColor.blue_20_75_136,
                alignment: .left,
                kerning: 0.2,
                lineHeight: nil
            )
        }
    }
}
