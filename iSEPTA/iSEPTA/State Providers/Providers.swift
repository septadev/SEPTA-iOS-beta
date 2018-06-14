// Septa. 2017

import Foundation

protocol StateProvider: class {}

class StateProviders {
    let preferenceProvider: UserPreferencesProviderProtocol
    let scheduleProvider: ScheduleDataProvider
    let alertProvider: AlertProvider
    let addressProvider: AddressLookupProvider
    let locationProvider: LocationProvider
    let favoritesProvider: FavoritesProvider
    let nextToArriveScheduleDataProvider: NextToArriveScheduleDataProvider
    let nextToArriveProvider: NextToArriveProvider
    let favoritesNextToArriveProvider: FavoritesNextToArriveProvider
    let alertScheduleDataProvider: AlertScheduleDataProvider
    let alertDetailProvider: AlertDetailProvider
    let genericAlertDetailProvider: StateProvider
    let tripDetailStateProvider: TripDetailStateProvider
    let databaseUpdateProvider: DatabaseUpdateProvider
    let databaseDownloadProvider: DatabaseDownloadProvider

    init(preferenceProvider: UserPreferencesProviderProtocol = UserPreferencesProvider.sharedInstance,
         scheduleProvider: ScheduleDataProvider = ScheduleDataProvider.sharedInstance,
         alertProvider: AlertProvider = AlertProvider.sharedInstance,
         addressProvider: AddressLookupProvider = AddressLookupProvider.sharedInstance,
         locationProvider: LocationProvider = LocationProvider.sharedInstance,
         favoritesProvider: FavoritesProvider = FavoritesProvider.sharedInstance,
         nextToArriveScheduleDataProvider: NextToArriveScheduleDataProvider = NextToArriveScheduleDataProvider.sharedInstance,
         nextToArriveProvider: NextToArriveProvider = NextToArriveProvider.sharedInstance,
         favoritesNextToArriveProvider: FavoritesNextToArriveProvider = FavoritesNextToArriveProvider.sharedInstance,
         alertScheduleDataProvider: AlertScheduleDataProvider = AlertScheduleDataProvider.sharedInstance,
         alertDetailProvider: AlertDetailProvider = AlertDetailProvider.sharedInstance,
         genericAlertDetailProvider: StateProvider = GenericAlertDetailProviderFactory.generateProvider(),
         tripDetailStateProvider: TripDetailStateProvider = TripDetailStateProvider.sharedInstance,
         databaseUpdateProvider: DatabaseUpdateProvider = DatabaseUpdateProvider.sharedInstance,
         databaseDownloadProvider: DatabaseDownloadProvider = DatabaseDownloadProvider.sharedInstance
    ) {
        self.preferenceProvider = preferenceProvider
        self.scheduleProvider = scheduleProvider
        self.alertProvider = alertProvider
        self.addressProvider = addressProvider
        self.locationProvider = locationProvider
        self.favoritesProvider = favoritesProvider
        self.nextToArriveScheduleDataProvider = nextToArriveScheduleDataProvider
        self.nextToArriveProvider = nextToArriveProvider
        self.favoritesNextToArriveProvider = favoritesNextToArriveProvider
        self.alertScheduleDataProvider = alertScheduleDataProvider
        self.alertDetailProvider = alertDetailProvider
        self.genericAlertDetailProvider = genericAlertDetailProvider
        self.tripDetailStateProvider = tripDetailStateProvider
        self.databaseUpdateProvider = databaseUpdateProvider
        self.databaseDownloadProvider = databaseDownloadProvider
    }
}
