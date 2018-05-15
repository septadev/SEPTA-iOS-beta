
// Septa. 2017

import SeptaSchedule
import ReSwift

protocol FavoritesState_FavoritesExistWatcherDelegate: AnyObject {
    func favoritesState_FavoritesExistUpdated(bool: Bool)
}

class FavoritesState_FavoritesExistWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = Bool

    weak var delegate: FavoritesState_FavoritesExistWatcherDelegate?

    init(delegate: FavoritesState_FavoritesExistWatcherDelegate) {
        self.delegate = delegate
        super.init()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.favoritesState.favoritesExist }
        }
    }

    func newState(state: StoreSubscriberStateType) {
        delegate?.favoritesState_FavoritesExistUpdated(bool: state)
    }
}
