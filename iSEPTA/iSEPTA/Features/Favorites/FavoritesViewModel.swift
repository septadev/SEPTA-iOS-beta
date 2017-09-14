//
//  FavoritesViewModel.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/13/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit
import ReSwift
import SeptaSchedule

class FavoritesViewModel: StoreSubscriber, SubscriberUnsubscriber {

    typealias StoreSubscriberStateType = [Favorite]

    let delegate: UpdateableFromViewModel

    init(delegate: UpdateableFromViewModel = FavoritesViewModelDelegate()) {
        self.delegate = delegate
    }

    var favoriteViewModels = [FavoriteNextToArriveViewModel]()

    func newState(state: StoreSubscriberStateType) {
        favoriteViewModels = state.map { FavoriteNextToArriveViewModel(favorite: $0, delegate: delegate) }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.favoritesState.favorites
            }.skipRepeats { $0 == $1 }
        }
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }
}

class FavoritesViewModelDelegate: UpdateableFromViewModel {
    func viewModelUpdated() {
    }

    func updateActivityIndicator(animating _: Bool) {
    }

    func displayErrorMessage(message _: String, shouldDismissAfterDisplay _: Bool) {
    }
}
