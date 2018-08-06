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

protocol DeleteTimeFrameDelegate: class {
    func deleteTimeframe(index: Int)
}

class TimeframeGroupView: UIView, StoreSubscriber, DeleteTimeFrameDelegate {
    typealias StoreSubscriberStateType = Int

    @IBOutlet var stackView: UIStackView!

    var timeFrame1: TimeframeView!
    @IBOutlet var timeFrame1Wrapper: XibView!

    var timeFrame2: TimeframeView!
    @IBOutlet var timeFrame2Wrapper: XibView!

    var addTimeframeButtonView: AddTimeframeButtonView!
    @IBOutlet var addTimeFrameWrapper: XibView!

    override func willMove(toSuperview superview: UIView?) {
        guard let _ = superview else { return }
        super.willMove(toSuperview: superview)
        if let timeframeView = timeFrame1Wrapper.contentView as? TimeframeView {
            timeFrame1 = timeframeView
            timeFrame1.configureSubscriptions(index: 0)
            timeFrame1.subscribe()
            timeFrame1.deleteTimeFrameDelegate = self
        }
        if let timeframeView = timeFrame2Wrapper.contentView as? TimeframeView {
            timeFrame2 = timeframeView
            timeFrame2.configureSubscriptions(index: 1)
            timeFrame2.deleteTimeFrameDelegate = self
        }
        if let buttonView = addTimeFrameWrapper.contentView as? AddTimeframeButtonView {
            addTimeframeButtonView = buttonView
            addTimeframeButtonView.addTimeFrameButton.addTarget(self, action: #selector(addTimeFrameButtonTapped(sender:)), for: .touchUpInside)
            addTimeframeButtonView.addTimeFrameButton.setTitleColor(SeptaColor.blue_20_75_136, for: .normal)
        }
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.preferenceState.pushNotificationPreferenceState.notificationTimeWindows.count }
        }
    }

    @objc func addTimeFrameButtonTapped(sender _: UIButton) {
        guard let viewController = UIResponder.parentViewController(forView: self) else { return }
        let action = InsertNewPushTimeframe(viewController: viewController)
        store.dispatch(action)
    }

    func newState(state: Int) {
        stackView.clearSubviews()
        arrangeViewsBasedOnTimeWindowsCount(count: state)
        if state == 2 {
            timeFrame2.configureSubscriptions(index: 1)
            timeFrame2.subscribe()
            timeFrame1.closeTimeFrameButton.isHidden = false
        } else {
            timeFrame1.closeTimeFrameButton.isHidden = true
        }
    }

    func deleteTimeframe(index: Int) {
        timeFrame2.unsubscribe()
        timeFrame1.closeTimeFrameButton.isHidden = true
        guard let viewController = UIResponder.parentViewController(forView: self) else { return }
        let action = DeleteTimeframe(index: index, viewController: viewController)
        store.dispatch(action)
    }

    func arrangeViewsBasedOnTimeWindowsCount(count: Int) {
        switch count {
        case 0: fatalError("Default time windows are not configured Correctly.")
        case 1:
            stackView.addArrangedSubview(timeFrame1)
            stackView.addArrangedSubview(addTimeframeButtonView)
        case 2:
            stackView.addArrangedSubview(timeFrame1)
            stackView.addArrangedSubview(timeFrame2)
        default: break
        }
    }

    deinit {
        store.unsubscribe(self)
    }
}
