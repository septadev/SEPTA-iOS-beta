// Septa. 2017

import Foundation

class StateProviders {
    let preferenceProvider: PreferencesProviderProtocol
    let scheduleProvider: ScheduleProvider

    init(preferenceProvider: PreferencesProviderProtocol = PreferencesProvider.sharedInstance,
         scheduleProvider: ScheduleProvider = ScheduleProvider.sharedInstance) {
        self.preferenceProvider = preferenceProvider
        self.scheduleProvider = scheduleProvider
    }
}
