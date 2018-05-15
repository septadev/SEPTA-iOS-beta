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

class NextToArriveTripViewController: UIViewController, UpdateableFromViewModel {

    @IBOutlet var startLabel: UILabel!
    @IBOutlet var endLabel: UILabel!

    let viewModel = NextToArriveTripViewModel()

    override func viewDidLoad() {
        viewModel.delegate = self
        view.backgroundColor = SeptaColor.navBarBlue

        view.addStandardDropShadow()
    }

    @IBAction func refreshButtonTapped(_: Any) {
        guard let target = store.state.targetForScheduleActions() else { return }

        switch target {
        case .nextToArrive:
            let action = NextToArriveRefreshDataRequested(refreshUpdateRequested: true)
            store.dispatch(action)
        case .favorites:
            guard var nextToArriveFavorite = store.state.favoritesState.nextToArriveFavorite else { return }
            nextToArriveFavorite.refreshDataRequested = true
            let favoriteAction = RequestFavoriteNextToArriveUpdate(favorite: nextToArriveFavorite, description: "User manually refreshed a favorite in Next to Arrive")
            store.dispatch(favoriteAction)
        default:
            break
        }
    }

    func viewModelUpdated() {
        startLabel.text = viewModel.startName()
        endLabel.text = viewModel.endName()
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
    func newState(state: ScheduleRequest) {
        scheduleRequest = state
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
