//
//  CustomPushNotificationsTimeframeView.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/27/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

protocol TimeframeBoundaryViewDelegate: class {
    func willEditTimeOfDay(boundaryType: TimeFrameBoundaryType)
}

@IBDesignable
class TimeframeView: UIView, TimeframeBoundaryViewDelegate {
    @IBOutlet var timeframeLabel: UILabel! {
        didSet {
            guard let text = timeframeLabel.text else { return }
            setTimeFrameLabelText(text: text)
        }
    }

    @IBOutlet var closeTimeFrameButton: UIButton!
    weak var deleteTimeFrameDelegate: DeleteTimeFrameDelegate?

    @IBAction func closeTimeframeButtonTapped(_: Any) {
        deleteTimeFrameDelegate?.deleteTimeframe(index: timeFrameIndex)
    }

    func setTimeFrameLabelText(text: String) {
        timeframeLabel.attributedText = text.attributed(
            fontSize: 14,
            fontWeight: .bold,
            textColor: SeptaColor.black87,
            alignment: .left,
            kerning: 0.1,
            lineHeight: 24
        )
    }

    @IBOutlet var centeringView: UIView! {
        didSet {
            centeringView.backgroundColor = UIColor.clear
        }
    }

    @IBOutlet var dividerView: UIView! {
        didSet {
            dividerView.backgroundColor = SeptaColor.gray_198
        }
    }

    @IBOutlet var startOfDay: XibView!
    @IBOutlet var endOfDay: XibView!

    var timeFrameIndex: Int = 0 {
        didSet {
            setTimeFrameLabelText(text: "Timeframe \(timeFrameIndex + 1)")
        }
    }

    func willEditTimeOfDay(boundaryType: TimeFrameBoundaryType) {
        let timeWindow = store.state.preferenceState.pushNotificationPreferenceState.notificationTimeWindows[timeFrameIndex]
        if boundaryType == .start {
            SelectTimeOfDayViewController.minimumDateRequirement = nil
            SelectTimeOfDayViewController.maximumDateRequirement = timeWindow.endMinute.timeOnlyDate

        } else {
            SelectTimeOfDayViewController.minimumDateRequirement = timeWindow.startMinute.timeOnlyDate
            SelectTimeOfDayViewController.maximumDateRequirement = nil
        }
    }

    func configureSubscriptions(index: Int) {
        timeFrameIndex = index

        configureStartSubscription(index: index)
        configureEndSubscription(index: index)
    }

    func subscribe() {
        guard let startView = startOfDay.contentView as? TimeframeBoundaryView,
            let endView = endOfDay.contentView as? TimeframeBoundaryView else { return }
        startView.subscribe()
        endView.subscribe()
    }

    func unsubscribe() {
        guard let startView = startOfDay.contentView as? TimeframeBoundaryView,
            let endView = endOfDay.contentView as? TimeframeBoundaryView else { return }
        startView.unsubscribe()
        endView.unsubscribe()
    }

    func configureStartSubscription(index: Int) {
        let timeWindows = store.state.preferenceState.pushNotificationPreferenceState.notificationTimeWindows
        guard index < timeWindows.count, let startView = startOfDay.contentView as? TimeframeBoundaryView else { return }
        startView.timeFrameBoundaryType = .start
        startView.delegate = self
        startView.setHeadingLabel(text: "Start:")

        startView.subscriptonTarget = { $0.preferenceState.pushNotificationPreferenceState.notificationTimeWindows[index].startMinute }
        startView.actionTarget = { date in
            guard let minutesSinceMidnight = MinutesSinceMidnight(date: date) else { return }
            let block: (UserPreferenceState) -> UserPreferenceState = {
                var newState = $0
                newState.pushNotificationPreferenceState.notificationTimeWindows[index].startMinute = minutesSinceMidnight
                return newState
            }
            let action = UpdatePushNotificationTimeframe(block: block)
            store.dispatch(action)
        }
    }

    private func configureEndSubscription(index: Int) {
        let timeWindows = store.state.preferenceState.pushNotificationPreferenceState.notificationTimeWindows
        guard index < timeWindows.count, let endView = endOfDay.contentView as? TimeframeBoundaryView else { return }
        endView.timeFrameBoundaryType = .end
        endView.delegate = self
        endView.setHeadingLabel(text: "Until:")
        endView.subscriptonTarget =
            { $0.preferenceState.pushNotificationPreferenceState.notificationTimeWindows[index].endMinute }
        endView.actionTarget = { date in
            guard let minutesSinceMidnight = MinutesSinceMidnight(date: date) else { return }
            let block: (UserPreferenceState) -> UserPreferenceState = {
                var newState = $0
                newState.pushNotificationPreferenceState.notificationTimeWindows[index].endMinute = minutesSinceMidnight
                return newState
            }
            let action = UpdatePushNotificationTimeframe(block: block)
            store.dispatch(action)
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 75)
    }
}
