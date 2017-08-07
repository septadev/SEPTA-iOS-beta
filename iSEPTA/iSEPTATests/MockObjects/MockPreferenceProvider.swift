// SEPTA.org, created on 8/7/2017.

import XCTest
@testable import Septa

/// MockPreferenceProvider purpose: returns made up user preferences
class MockPreferenceProvider: PreferencesProviderProtocol {
    var preferenceSet: [UserPreferenceKeys: String]?
    private let preferences: [UserPreferenceKeys: String]

    init(preferences: [UserPreferenceKeys: String]) {
        self.preferences = preferences
    }

    func setStringPreference(preference: String, forKey key: UserPreferenceKeys) {
        preferenceSet?[key] = preference
    }

    func stringPreference(forKey key: UserPreferenceKeys) -> String? {
        return preferences[key]
    }
}
