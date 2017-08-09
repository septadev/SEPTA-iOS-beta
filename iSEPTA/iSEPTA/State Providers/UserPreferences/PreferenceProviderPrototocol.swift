// Septa. 2017

import Foundation

protocol PreferencesProviderProtocol {
    func setStringPreference(preference: String, forKey key: UserPreferenceKeys)
    func stringPreference(forKey key: UserPreferenceKeys) -> String?
    func retrievePersistedState() -> UserPreferenceState
    func subscribe()
}
