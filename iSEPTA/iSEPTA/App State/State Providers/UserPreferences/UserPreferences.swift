// Septa. 2017

import Foundation
import ReSwift

protocol PreferencesProviderProtocol {
    func setStringPreference(preference: String, forKey key: UserPreferenceKeys)
    func stringPreference(forKey key: UserPreferenceKeys) -> String?
}

class PreferencesProvider: PreferencesProviderProtocol, StoreSubscriber {
    typealias StoreSubscriberStateType = UserPreferenceState

    private let defaults = UserDefaults.standard
    static let sharedInstance = PreferencesProvider()

    private init() {
    }

    func setStringPreference(preference: String, forKey key: UserPreferenceKeys) {
        defaults.set(preference, forKey: key.rawValue)
    }

    func stringPreference(forKey key: UserPreferenceKeys) -> String? {
        if let preference = defaults.string(forKey: key.rawValue) {
            return preference
        } else {
            return key.defaultValue()
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

    func newState(state _: StoreSubscriberStateType) {
    }
}
