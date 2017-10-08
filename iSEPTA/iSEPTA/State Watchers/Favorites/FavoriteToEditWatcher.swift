
// Septa. 2017

import SeptaSchedule
import ReSwift

protocol FavoritesState_FavoriteToEditWatcherDelegate: AnyObject {
    func favoritesState_FavoriteToEditUpdated(favorite: Favorite?)
}

class FavoritesState_FavoriteToEditWatcher: BaseWatcher, StoreSubscriber {

    typealias StoreSubscriberStateType = Bool

    weak var delegate: FavoritesState_FavoriteToEditWatcherDelegate?

    init(delegate: FavoritesState_FavoriteToEditWatcherDelegate) {
        self.delegate = delegate
        super.init()
        subscribe()
    }

    func subscribe() {
        store.subscribe(self) {
            $0.select { $0.favoritesState.hasFavoriteToEdit }
        }
    }

    func newState(state _: StoreSubscriberStateType) {
        let favoriteToEdit = store.state.favoritesState.favoriteToEdit
        delegate?.favoritesState_FavoriteToEditUpdated(favorite: favoriteToEdit)
    }
}
