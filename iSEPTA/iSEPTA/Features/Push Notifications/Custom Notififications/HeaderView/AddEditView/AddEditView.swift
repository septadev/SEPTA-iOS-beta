//
//  CustomPushNotificationsHeaderView.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/30/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

protocol CustomNotificationEditDelegate: class {
    func isCurrentlyEditing(_ isCurrentlyEditing: Bool)
}

class AddEditView: UIView {
    var isCurrentlyEditing: Bool = false

    @IBOutlet var myNotificationsLabel: UILabel! {
        didSet {
            guard let text = myNotificationsLabel.text else { return }
            myNotificationsLabel.attributedText = text.attributed(
                fontSize: 13,
                fontWeight: .regular,
                textColor: SeptaColor.gray_198,
                alignment: .center,
                kerning: -0.1,
                lineHeight: 18
            )
        }
    }

    weak var editDelegate: CustomNotificationEditDelegate?

    @IBOutlet var dividerView: UIView! { didSet { dividerView.backgroundColor = SeptaColor.gray_198 } }

    @IBOutlet var addButton: UIButton! { didSet { styleButton(button: addButton, text: "Add") } }

    @IBOutlet var editButton: UIButton! { didSet { styleButton(button: editButton, text: "Edit") } }

    @IBAction func editButtonTapped(_: Any) {
        isCurrentlyEditing = !isCurrentlyEditing
        styleButton(button: editButton, text: isCurrentlyEditing ? "Done" : "Edit")
        editDelegate?.isCurrentlyEditing(isCurrentlyEditing)
    }
    func styleButton(button: UIButton, text: String) {
        let attributedText = text.attributed(
            fontSize: 15,
            fontWeight: .regular,
            textColor: SeptaColor.blue_20_75_136
        )
        button.setAttributedTitle(attributedText, for: .normal)
    }
    @IBAction func AddButtonTapped(_: Any) {
        let navigationState = NavigationStackState(viewControllers: [.alertsViewController], modalViewController: nil)
        let navigationAction = InitializeNavigationState(navigationController: .alerts, navigationStackState: navigationState, description: "Initializing state")
        store.dispatch(navigationAction)

        let action = SwitchTabs(activeNavigationController: .alerts, description: "Adding a route to push notifications")
        store.dispatch(action)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 44)
    }
}
