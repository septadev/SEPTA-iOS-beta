//
//  AlertDetailFooterView.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/1/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import UIKit

class AlertDetailFooterView: UIView {
    var pushNotificationRoute: PushNotificationRoute? {
        didSet {
            guard let route = pushNotificationRoute else { return }
            pushNotificationToggleView.isOn = store.state.preferenceState.pushNotificationPreferenceState.routeIds.contains(route)
        }
    }

    @IBAction func toggleNotificationsValueChanged(_ sender: UISwitch) {
        guard let route = pushNotificationRoute else { return }
        DispatchQueue.main.async {
            if sender.isOn {
                store.dispatch(AddPushNotificationRoute(route: route))
            } else {
                store.dispatch(RemovePushNotificationRoute(routes: [route]))
            }
        }
    }

    @IBAction func userTappedOnViewNotificationPreferences(_: Any) {
        store.dispatch(SwitchTabs(activeNavigationController: .more, description: "User wants to view preferences"))
        let navigationStackState = NavigationStackState(viewControllers: [.moreViewController, .managePushNotficationsController], modalViewController: nil)
        let action = InitializeNavigationState(navigationController: .more, navigationStackState: navigationStackState, description: "Deep Linking into More")
        store.dispatch(action)
    }

    @IBOutlet var pushNotificationToggleView: UISwitch!

    @IBOutlet var subscribeLabel: UILabel!
//    {
//        didSet {
//            guard let text = subscribeLabel.text else { return }
//            subscribeLabel.attributedText = text.attributed(
//                fontSize: 14,
//                fontWeight: .bold
//            )
//            subscribeLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 93
//            subscribeLabel.setNeedsLayout()
//        }
//    }

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
