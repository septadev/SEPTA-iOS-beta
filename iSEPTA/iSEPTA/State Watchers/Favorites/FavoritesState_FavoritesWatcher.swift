
// Septa. 2017

import ReSwift
import SeptaSchedule

protocol FavoritesState_FavoritesWatcherDelegate: AnyObject {
    func favoritesState_FavoritesUpdated(favorites: [Favorite])
}

class FavoritesState_FavoritesWatcher: BaseWatcher, StoreSubscriber {
    typealias StoreSubscriberStateType = [Favorite]

    weak var delegate: FavoritesState_FavoritesWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.favoritesState.favorites }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.favoritesState_FavoritesUpdated(favorites: state)
    }
}
