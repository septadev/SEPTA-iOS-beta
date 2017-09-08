// Septa. 2017

import Foundation

class StateProviders {
    let preferenceProvider: UserPreferencesProviderProtocol
    let scheduleProvider: ScheduleDataProvider
    let alertProvider: AlertProvider
    let addressProvider: AddressLookupProvider
    let locationProvider: LocationProvider
    let favoritesProvider: FavoritesProvider
    let nextToArriveScheduleDataProvider: NextToArriveScheduleDataProvider
    let nextToArriveProvider: NextToArriveProvider

    init(preferenceProvider: UserPreferencesProviderProtocol = UserPreferencesProvider.sharedInstance,
         scheduleProvider: ScheduleDataProvider = ScheduleDataProvider.sharedInstance,
         alertProvider: AlertProvider = AlertProvider.sharedInstance,
         addressProvider: AddressLookupProvider = AddressLookupProvider.sharedInstance,
         locationProvider: LocationProvider = LocationProvider.sharedInstance,
         favoritesProvider: FavoritesProvider = FavoritesProvider.sharedInstance,
         nextToArriveScheduleDataProvider: NextToArriveScheduleDataProvider = NextToArriveScheduleDataProvider.sharedInstance,
         nextToArriveProvider: NextToArriveProvider = NextToArriveProvider.sharedInstance

    ) {
        self.preferenceProvider = preferenceProvider
        self.scheduleProvider = scheduleProvider
        self.alertProvider = alertProvider
        self.addressProvider = addressProvider
        self.locationProvider = locationProvider
        self.favoritesProvider = favoritesProvider
        self.nextToArriveScheduleDataProvider = nextToArriveScheduleDataProvider
        self.nextToArriveProvider = nextToArriveProvider
    }
}
