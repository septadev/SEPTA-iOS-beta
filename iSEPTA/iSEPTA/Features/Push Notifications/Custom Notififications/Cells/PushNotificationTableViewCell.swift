//
//  PushNotificationTableViewCell.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/1/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import UIKit

class PushNotificationTableViewCell: UITableViewCell {
    @IBOutlet var iconView: UIImageView!

    @IBOutlet var pillView: UIView!

    var pushNotificationRoute: PushNotificationRoute? {
        didSet {
            guard let route = pushNotificationRoute else { return }
            iconView.image = UIImage(named: route.transitMode.highlightedImageName())
            pillView.backgroundColor = Route.colorForRouteId(route.routeId, transitMode: route.transitMode)
            routeNameText = route.routeName
            toggleSwitch.isOn = route.isEnabled
        }
    }

    @IBAction func toggleSwitchChanged(_ sender: UISwitch) {
        guard let route = pushNotificationRoute else { return }
        let newRoute = PushNotificationRoute(routeId: route.routeId, routeName: route.routeName, transitMode: route.transitMode, isEnabled: sender.isOn)
        guard let viewController = UIResponder.parentViewController(forView: self) else { return }
        store.dispatch(UpdatePushNotificationRoute(route: newRoute, postImmediately: false, viewController: viewController))
    }

    var routeNameText: String? {
        didSet {
            guard let text = routeNameText else { return }
            routeNameLabel.attributedText = text.attributed(
                fontSize: 16,
                fontWeight: .bold,
                textColor: SeptaColor.blue_27_78_142
            )
        }
    }

    @IBOutlet private var routeNameLabel: UILabel!

    @IBOutlet var toggleSwitch: UISwitch!

    @IBOutlet var bottomDivider: UIView! { didSet { bottomDivider.backgroundColor = SeptaColor.gray_198 } }
}
