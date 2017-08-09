// Septa. 2017

import Foundation
import ReSwift

class PreferencesProvider: PreferencesProviderProtocol, StoreSubscriber {
    typealias StoreSubscriberStateType = UserPreferenceState

    private let defaults = UserDefaults.standard
    static let sharedInstance = PreferencesProvider()

    private var subscribed = false

    private init() { }

    func retrievePersistedState() -> UserPreferenceState {
        var transitMode: TransitMode?
        if let prefString = stringPreference(forKey: .preferredTransitMode), let prefObj = TransitMode(rawValue: prefString) {
            transitMode = prefObj
        }
        let preferenceState = UserPreferenceState(transitMode: transitMode)
        return preferenceState
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

    deinit {
        unsubscribe()
    }

    func newState(state: StoreSubscriberStateType) {
        guard let transitMode = state.transitMode?.rawValue else { return }
        setStringPreference(preference: transitMode, forKey: UserPreferenceKeys.preferredTransitMode)
    }
}
