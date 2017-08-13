// Septa. 2017

import Foundation

class StateProviders {
    let preferenceProvider: UserPreferencesProviderProtocol
    let scheduleProvider: ScheduleProvider

    init(preferenceProvider: UserPreferencesProviderProtocol = UserPreferencesProvider.sharedInstance,
         scheduleProvider: ScheduleProvider = ScheduleProvider.sharedInstance) {
        self.preferenceProvider = preferenceProvider
        self.scheduleProvider = scheduleProvider
    }
}
