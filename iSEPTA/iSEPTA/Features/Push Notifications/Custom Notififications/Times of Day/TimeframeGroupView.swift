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

class TimeframeGroupView: UIView, StoreSubscriber {
    typealias StoreSubscriberStateType = TimeWindows

    @IBOutlet var stackView: UIStackView!

    var timeFrame1: TimeframeView!
    @IBOutlet var timeFrame1Wrapper: XibView!

    var timeFrame2: TimeframeView!
    @IBOutlet var timeFrame2Wrapper: XibView!

    @IBOutlet var addTimeFrameWrapper: XibView!

    override func willMove(toSuperview superview: UIView?) {
        guard let _ = superview else { return }
        super.willMove(toSuperview: superview)
        if let timeframeView = timeFrame1Wrapper.contentView as? TimeframeView {
            timeFrame1 = timeframeView
        }
        if let timeframeView = timeFrame2Wrapper.contentView as? TimeframeView {
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
            timeFrame1.setTimeFrameIndex(index: 0)
            stackView.addArrangedSubview(timeFrame1)
        case 2: break

        default: break
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
