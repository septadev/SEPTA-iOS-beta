// Septa. 2017

import Foundation

protocol PreferencesProviderProtocol {
    func setStringPreference(preference: String, forKey key: UserPreferenceKeys)
    func stringPreference(forKey key: UserPreferenceKeys) -> String?
}

class PreferencesProvider: PreferencesProviderProtocol {
    // Defaults

    private let defaults = UserDefaults.standard
    static let sharedInstance = PreferencesProvider()

    private init() {}

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
}
