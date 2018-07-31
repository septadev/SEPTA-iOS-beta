//
//  TimesOfDayView.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/31/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

typealias TimeWindows = [NotificationTimeWindow]

class CustomPushNotificationsSelectTimeframeView: UIView, StoreSubscriber {
    typealias StoreSubscriberStateType = TimeWindows

    @IBOutlet var stackView: UIStackView!

    var timeFrame1: CustomPushNotificationsTimeframeView!
    @IBOutlet var timeFrame1Wrapper: XibView!

    var timeFrame2: CustomPushNotificationsTimeframeView!
    @IBOutlet var timeFrame2Wrapper: XibView!

    @IBOutlet var addTimeFrameWrapper: XibView!

    override func willMove(toSuperview superview: UIView?) {
        guard let _ = superview else { return }
        super.willMove(toSuperview: superview)
        if let timeframeView = timeFrame1Wrapper.contentView as? CustomPushNotificationsTimeframeView {
            timeFrame1 = timeframeView
        }
        if let timeframeView = timeFrame2Wrapper.contentView as? CustomPushNotificationsTimeframeView {
            timeFrame2 = timeframeView
        }
        if let button = addTimeFrameWrapper.contentView as? UIButton {
            button.addTarget(self, action: #selector(addTimeFrameButtonTapped(sender:)), for: .touchUpInside)
        }
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.preferenceState.pushNotificationPreferenceState.notificationTimeWindows }
        }
    }

    @objc func addTimeFrameButtonTapped(sender _: UIButton) {
    }

    func newState(state: TimeWindows) {
        stackView.clearSubviews()
        arrangeViewsBasedOnTimeWindowsCount(timeWindows: state)
    }

    func arrangeViewsBasedOnTimeWindowsCount(timeWindows: TimeWindows) {
        switch timeWindows.count {
        case 0: fatalError("Default time windows are not configured Correctly.")
        case 1:
            stackView.addArrangedSubview(timeFrame1Wrapper)
            timeFrame1.setTimeWindow(index: 1, timeWindow: timeWindows[0])
            stackView.addArrangedSubview(addTimeFrameWrapper)

        case 2:
            stackView.addArrangedSubview(timeFrame1Wrapper)
            timeFrame1.setTimeWindow(index: 1, timeWindow: timeWindows[0])
            stackView.addArrangedSubview(timeFrame2Wrapper)
            timeFrame2.setTimeWindow(index: 2, timeWindow: timeWindows[1])

        default: break
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
