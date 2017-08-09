// Septa. 2017

import Foundation

class StateProviders {
    let preferenceProvider: PreferencesProviderProtocol

    init(preferenceProvider: PreferencesProviderProtocol = PreferencesProvider.sharedInstance) {
        self.preferenceProvider = preferenceProvider
    }
}
