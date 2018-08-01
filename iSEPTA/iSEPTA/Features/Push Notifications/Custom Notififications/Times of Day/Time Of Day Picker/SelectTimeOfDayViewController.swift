//
//  SelectTimeOfDayViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 7/31/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit

class SelectTimeOfDayViewController: UIViewController, IdentifiableController, StoreSubscriber {
    var viewController: ViewController = .timeOfDayPickerController
    typealias StoreSubscriberStateType = MinutesSinceMidnight

    /// where in the state tree should the subscribption be made
    static var subscriptonTarget: ((AppState) -> MinutesSinceMidnight)?

    static var actionTarget: ((Date) -> Void)? // Action to take when the value changes

    static var minimumDateRequirement: Date?
    static var maximumDateRequirement: Date?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribe()
    }

    @IBOutlet var datePicker: UIDatePicker!

    @IBAction func datePickerValueChanged(_: Any) {
        guard let actionTarget = SelectTimeOfDayViewController.actionTarget else { return }
        actionTarget(datePicker.date)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribe()
    }

    func subscribe() {
        guard let subscriptionTarget = SelectTimeOfDayViewController.subscriptonTarget else { return }
        store.subscribe(self, transform: { $0.select(subscriptionTarget) })
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }

    @IBAction func doneButtonTapped(_: Any) {
        let action = DismissModal(description: "Closing out the Time Picker View Controller")
        store.dispatch(action)
    }

    func newState(state: StoreSubscriberStateType) {
        guard let date = state.timeOnlyDate else { return }
        datePicker.setDate(date, animated: false)
        datePicker.minimumDate = SelectTimeOfDayViewController.minimumDateRequirement?.addingTimeInterval(60 * 15)
        datePicker.maximumDate = SelectTimeOfDayViewController.maximumDateRequirement?.addingTimeInterval(-60 * 15)
    }
}
