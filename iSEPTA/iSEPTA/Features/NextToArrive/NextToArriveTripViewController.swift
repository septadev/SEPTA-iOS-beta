//
//  NextToArriveTripViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import UIKit
import SeptaSchedule

class NextToArriveTripViewController: UIViewController, UpdateableFromViewModel, NextToArriveReverseTripDelegate {
    @IBOutlet var startLabel: UILabel!
    @IBOutlet var endLabel: UILabel!
    @IBOutlet weak var swapRouteImage: UIImageView! {
        didSet {
            swapRouteImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(swapRoutes(_:))))
        }
    }

    let viewModel = NextToArriveTripViewModel()
    var nextToArriveReverseTrip: NextToArriveReverseTrip?
    var favoriteNextToArriveReverseTrip: FavoriteNextToArriveReverseTrip?

    override func viewDidLoad() {
        viewModel.delegate = self
        view.backgroundColor = SeptaColor.navBarBlue
        view.addStandardDropShadow()
    }

    func viewModelUpdated() {
        startLabel.text = viewModel.startName()
        endLabel.text = viewModel.endName()
    }

    @objc func swapRoutes(_: UITapGestureRecognizer) {
        swapRouteImage.alpha = 0.5

        if store.state.targetForScheduleActions() == .nextToArrive {
            initializeReverseTripForNextToArrive()
        } else {
            initializeReverseTripForFavorites()
        }
    }

    func initializeReverseTripForNextToArrive() {

        if let scheduleRequest = viewModel.scheduleRequest, let target = viewModel.target, swapRouteImage.isUserInteractionEnabled {
            nextToArriveReverseTrip = NextToArriveReverseTrip(target: target, scheduleRequest: scheduleRequest, delegate: self)
            nextToArriveReverseTrip?.reverseNextToArrive()
        }
    }

    func initializeReverseTripForFavorites() {
        guard let scheduleRequest = viewModel.scheduleRequest, let target = viewModel.target, swapRouteImage.isUserInteractionEnabled else { return }
        let status = store.state.favoritesState.nextToArriveReverseTripStatus

        if status == .noReverse {
            favoriteNextToArriveReverseTrip = FavoriteNextToArriveReverseTrip(target: target, scheduleRequest: scheduleRequest, delegate: self)
            favoriteNextToArriveReverseTrip?.reverseNextToArrive()
        } else if status == .didReverse {
            let action = UpdateFavoriteNextToArriveReverseTripStatus(nextToArriveReverseTripStatus: .noReverse)
            store.dispatch(action)
        }
    }

    func tripReverseCompleted() {
        swapRouteImage.alpha = 1.0
        swapRouteImage.isUserInteractionEnabled = true
    }

    func updateActivityIndicator(animating _: Bool) {
    }

    func displayErrorMessage(message _: String, shouldDismissAfterDisplay _: Bool) {
    }

}

class NextToArriveTripViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest

    weak var delegate: UpdateableFromViewModel? {
        didSet {
            subscribe()
        }
    }

    var scheduleRequest: ScheduleRequest?
    var target: TargetForScheduleAction?
    func newState(state: ScheduleRequest) {
        scheduleRequest = state
        guard let _ = state.selectedStart, let _ = state.selectedEnd else { return }
        delegate?.viewModelUpdated()
    }

    func viewTitle() -> String? {
        return scheduleRequest?.transitMode.nextToArriveDetailTitle()
    }

    func startName() -> String? {
        return scheduleRequest?.selectedStart?.stopName
    }

    func endName() -> String? {
        return scheduleRequest?.selectedEnd?.stopName
    }

    deinit {
        unsubscribe()
    }
}

extension NextToArriveTripViewModel: SubscriberUnsubscriber {

    func subscribe() {

        guard let target = store.state.targetForScheduleActions() else { return }
        self.target = target
        switch target {
        case .nextToArrive:
            store.subscribe(self) {
                $0.select {
                    $0.nextToArriveState.scheduleState.scheduleRequest
                }.skipRepeats { $0 == $1 }
            }
        case .favorites:
            store.subscribe(self) {
                $0.select {
                    $0.favoritesState.nextToArriveScheduleRequest
                }.skipRepeats { $0 == $1 }
            }
        default:
            break
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}
