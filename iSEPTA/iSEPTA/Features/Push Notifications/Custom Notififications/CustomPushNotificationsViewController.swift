//
//  CustomNotificationsViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/27/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class CustomPushNotificationsViewController: BaseNonModalViewController, StoreSubscriber, IdentifiableController {
    typealias StoreSubscriberStateType = PushNotificationPreferenceState

    @IBOutlet var instructionsLabel: UILabel! {
        didSet {
            guard let text = instructionsLabel.text else { return }
            instructionsLabel.attributedText = text.attributed(
                fontSize: 14,
                fontWeight: .regular,
                textColor: SeptaColor.black87,
                alignment: .center,
                kerning: 0.1,
                lineHeight: 20
            )
        }
    }

    var viewController: ViewController = .customPushNotificationsController
    var viewModel: CustomPushNotificationsViewModel = CustomPushNotificationsViewModel()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribe()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.unsubscribe(self)
    }

    func newState(state: StoreSubscriberStateType) {
        viewModel.stateUpdated(state)
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.preferenceState.pushNotificationPreferenceState }
        }
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        backButtonPopped(toParentViewController: parent)
    }
}
