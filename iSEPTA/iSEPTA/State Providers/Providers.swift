// Septa. 2017

import Foundation

class StateProviders {
    let preferenceProvider: UserPreferencesProviderProtocol
    let scheduleProvider: ScheduleDataProvider
    let alertProvider: AlertProvider
    let addressProvider: AddressLookupProvider

    init(preferenceProvider: UserPreferencesProviderProtocol = UserPreferencesProvider.sharedInstance,
         scheduleProvider: ScheduleDataProvider = ScheduleDataProvider.sharedInstance,
         alertProvider: AlertProvider = AlertProvider.sharedInstance,
         addressProvider: AddressLookupProvider = AddressLookupProvider.sharedInstance
    ) {
        self.preferenceProvider = preferenceProvider
        self.scheduleProvider = scheduleProvider
        self.alertProvider = alertProvider
        self.addressProvider = addressProvider
    }
}
