//
//  WeekOfDayView.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/30/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class DayOfWeekImageView: UIImageView {
    var dayOfWeek: DaysOfWeekOptionSet {
        switch dayOfWeekString {
        case "unknown": return DaysOfWeekOptionSet.unknown
        case "monday": return DaysOfWeekOptionSet.monday
        case "tuesday": return DaysOfWeekOptionSet.tuesday
        case "wednesday": return DaysOfWeekOptionSet.wednesday
        case "thursday": return DaysOfWeekOptionSet.thursday
        case "friday": return DaysOfWeekOptionSet.friday
        case "saturday": return DaysOfWeekOptionSet.saturday
        case "sunday": return DaysOfWeekOptionSet.sunday
        default: return DaysOfWeekOptionSet.unknown
        }
    }

    func respondToState(selectedDaysOfWeek: DaysOfWeekOptionSet) {
        isHighlighted = selectedDaysOfWeek.contains(dayOfWeek)
    }

    @IBInspectable var dayOfWeekString: String = "unknown"
}

class DayOfWeekView: UIView, StoreSubscriber {
    typealias StoreSubscriberStateType = DaysOfWeekOptionSet

    @IBOutlet var daysOfWeek: [DayOfWeekImageView]!

    override func awakeFromNib() {
        super.awakeFromNib()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.preferenceState.pushNotificationPreferenceState.daysOfWeek }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        _ = daysOfWeek.map { $0.respondToState(selectedDaysOfWeek: state) }
    }

    deinit {
        store.unsubscribe(self)
    }

    @IBAction func dayOfWeekViewTapped(_ sender: UITapGestureRecognizer) {
        guard let dayOfWeekView = sender.view as? DayOfWeekImageView else { return }

        dayOfWeekView.isHighlighted = !dayOfWeekView.isHighlighted
        submitAction(dayOfWeekView: dayOfWeekView)
    }

    func submitAction(dayOfWeekView: DayOfWeekImageView) {
        let action = UpdateDaysOfTheWeekForPushNotifications(dayOfWeek: dayOfWeekView.dayOfWeek, isActivated: dayOfWeekView.isHighlighted)
        store.dispatch(action)
    }

    @IBOutlet var dividerView: UIView! {
        didSet {
            dividerView.backgroundColor = SeptaColor.gray_198
        }
    }

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 54)
    }
}
