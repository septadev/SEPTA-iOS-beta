

// Septa. 2017

import SeptaSchedule
import ReSwift

protocol FavoriteState_SaveableFavoritesWatcherDelegate: AnyObject {
    func favoriteState_SaveableFavoritesUpdated(saveableFavorites: [String])
}

class FavoriteState_SaveableFavoritesWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = [String]

    weak var delegate: FavoriteState_SaveableFavoritesWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select {
                $0.favoritesState.saveableFavorites
            }.skipRepeats { $0 == $1 }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.favoriteState_SaveableFavoritesUpdated(saveableFavorites: state)
    }
}
