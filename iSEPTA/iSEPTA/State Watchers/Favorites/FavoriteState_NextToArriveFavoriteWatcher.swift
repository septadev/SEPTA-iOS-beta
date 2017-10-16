
// Septa. 2017

import SeptaSchedule
import ReSwift

protocol FavoriteState_NextToArriveFavoriteWatcherDelegate: AnyObject {
    func favoriteState_NextToArriveFavoriteUpdated(favorite: Favorite?)
}

class FavoriteState_NextToArriveFavoriteWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = Favorite?

    weak var delegate: FavoriteState_NextToArriveFavoriteWatcherDelegate? {
        didSet {
            subscribe()
        }
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.favoritesState.nextToArriveFavorite }.skipRepeats { $0 == $1 }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.favoriteState_NextToArriveFavoriteUpdated(favorite: state)
    }
}
