//
//  NextToArriveTripViewController.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/10/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import SeptaSchedule
import UIKit

class NextToArriveTripViewController: UIViewController, UpdateableFromViewModel, NextToArriveReverseTripDelegate {
    @IBOutlet var startLabel: UILabel!
    @IBOutlet var endLabel: UILabel!
    @IBOutlet var swapRouteImage: UIImageView! {
        didSet {
            swapRouteImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(swapRoutes(_:))))
        }
    }

    let viewModel = NextToArriveTripViewModel()
    var nextToArriveReverseTrip: NextToArriveReverseTrip?
    var favoriteNextToArriveReverseTrip: FavoriteNextToArriveReverseTrip?
    var reverseTripStatusWatcher: NextToArriveState_ReverseTripStatusWatcher?

    override func viewDidLoad() {
        viewModel.delegate = self
        view.backgroundColor = SeptaColor.navBarBlue
        view.addStandardDropShadow()
        undoReversedFavorites()
        watchForReverseTripStatusChanges()
    }

    func undoReversedFavorites() {
        store.dispatch(UndoReversedFavorite())
        store.dispatch(RemoveNextToArriveReverseTripStatus())
    }

    func viewModelUpdated() {
        startLabel.text = viewModel.startName()
        endLabel.text = viewModel.endName()
    }

    @objc func swapRoutes(_: UITapGestureRecognizer) {
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
        guard let scheduleRequest = viewModel.scheduleRequest, swapRouteImage.isUserInteractionEnabled else { return }
        favoriteNextToArriveReverseTrip = FavoriteNextToArriveReverseTrip(scheduleRequest: scheduleRequest, delegate: self)
        favoriteNextToArriveReverseTrip?.reverseFavorite()
    }

    func tripReverseCompleted() {
        swapRouteImage.isUserInteractionEnabled = true
    }

    func updateActivityIndicator(animating _: Bool) {
    }

    func displayErrorMessage(message _: String, shouldDismissAfterDisplay _: Bool) {
    }
}

extension NextToArriveTripViewController: NextToArriveReverseTripWatcherDelegate {
    func watchForReverseTripStatusChanges() {
        guard let target = store.state.targetForScheduleActions() else { return }
        var watcher: NextToArriveState_ReverseTripStatusWatcher?
        switch target {
        case .nextToArrive:
            watcher = NextToArriveState_ReverseTripStatusWatcher()
        case .favorites:
            watcher = FavoriteState_NextToArriveReverseTripStatusWatcher()
        default:
            watcher = nil
        }
        watcher?.delegate = self
        watcher?.subscribe()
        reverseTripStatusWatcher = watcher
    }

    func nextToArriveReverseTripStatusChanged(status: NextToArriveReverseTripStatus) {
        switch status {
        case .noReverse:
            swapRouteImage.alpha = 1
        case .didReverse:
            swapRouteImage.alpha = 0.5
        }
    }
}

class NextToArriveTripViewModel: StoreSubscriber {
    typealias StoreSubscriberStateType = ScheduleRequest

    var reverseTripStatusWatcher: NextToArriveState_ReverseTripStatusWatcher?

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
