// Septa. 2017

import Foundation
import ReSwift
import SeptaSchedule

class PreferencesProvider: PreferencesProviderProtocol, StoreSubscriber {
    typealias StoreSubscriberStateType = UserPreferenceState

    private let defaults = UserDefaults.standard
    static let sharedInstance = PreferencesProvider()
    private init() {}

    func retrievePersistedState() -> UserPreferenceState {

        var preferenceState = UserPreferenceState()
        preferenceState.startupTransitMode = TransitMode.bus
        return preferenceState
    }

    func setStringPreference(preference: String, forKey key: UserPreferenceKeys) {
        defaults.set(preference, forKey: key.rawValue)
    }

    func stringPreference(forKey key: UserPreferenceKeys) -> String? {
        if let preference = defaults.string(forKey: key.rawValue) {
            return preference
        } else {
            return nil
        }
    }

    func subscribe() {
        store.subscribe(self) { subscription in
            subscription.select(self.filterSubscription)
        }
    }

    func filterSubscription(state: AppState) -> UserPreferenceState {
        return state.preferenceState
    }

    func unsubscribe() {
        store.unsubscribe(self)
    }

    deinit {
        unsubscribe()
    }

    func newState(state: StoreSubscriberStateType) {
        guard let transitMode = state.startupTransitMode?.rawValue else { return }
        setStringPreference(preference: transitMode, forKey: UserPreferenceKeys.startupTransitMode)
    }
}
