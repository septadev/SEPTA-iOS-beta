//
//  TimeOfDayView.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/30/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

typealias MinutesSinceMidnightSubscription = (AppState) -> MinutesSinceMidnight

enum TimeFrameBoundaryType {
    case start
    case end
}

class TimeframeBoundaryView: UIView, StoreSubscriber {
    var timeFrameIndex: Int = 0

    typealias StoreSubscriberStateType = MinutesSinceMidnight

    @IBAction func timeOfDayViewTapped(_: Any) {
        guard let delegate = delegate else { return }
        let action = PresentModal(viewController: .timeOfDayPickerController, description: "Getting ready to pick a date")
        SelectTimeOfDayViewController.subscriptonTarget = subscriptonTarget
        SelectTimeOfDayViewController.actionTarget = actionTarget
        delegate.willEditTimeOfDay(boundaryType: timeFrameBoundaryType)
        store.dispatch(action)
    }

    /// where in the state tree should the subscribption be made
    var subscriptonTarget: MinutesSinceMidnightSubscription?

    func subscribe() {
        guard let subscriptionTarget = subscriptonTarget else { return }
        store.subscribe(self, transform: { $0.select(subscriptionTarget) })
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }

    /// where in the state tree should the subscribption be made
    var actionTarget: ((Date) -> Void)?

    var timeFrameBoundaryType: TimeFrameBoundaryType!
    weak var delegate: TimeframeBoundaryViewDelegate?

    @IBOutlet var headingLabel: UILabel! {
        didSet {
            guard let text = headingLabel.text else { return }
            setHeadingLabel(text: text)
        }
    }

    @IBOutlet var timeOfDayLabel: UILabel! {
        didSet {
            guard let text = timeOfDayLabel.text else { return }
            setTimeOfDayLabel(text: text)
        }
    }

    func setTimeOfDayLabel(text: String) {
        timeOfDayLabel.attributedText = text.attributed(
            fontSize: 14,
            fontWeight: .bold,
            textColor: SeptaColor.blue_27_78_142,
            alignment: .left,
            kerning: 0.1,
            lineHeight: 24
        )
    }

    func setHeadingLabel(text: String) {
        headingLabel.attributedText = text.attributed(
            fontSize: 14,
            fontWeight: .regular,
            textColor: SeptaColor.black87,
            alignment: .left,
            kerning: 0.1,
            lineHeight: 24
        )
    }

    func setTime(date: Date?) {
        guard let date = date else { return }
        setTimeOfDayLabel(text: DateFormatters.timeFormatter.string(from: date))
    }

    func configure(heading: String, timeFrameIndex _: Int, subscription: @escaping MinutesSinceMidnightSubscription) {
        setHeadingLabel(text: heading)
        subscriptonTarget = subscription
    }

    func newState(state: MinutesSinceMidnight) {
        setTime(date: state.timeOnlyDate)
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 44)
    }

    deinit {
        unsubscribe()
    }
}
