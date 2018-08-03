// Septa. 2017

import Crashlytics
import Fabric
import Firebase
import NotificationCenter
import ReSwift
import SeptaSchedule
import UIKit
import UserNotifications

let store = Store<AppState>(
    reducer: AppStateReducer.mainReducer,
    state: nil,
    middleware: [loggingMiddleware, nextToArriveMiddleware, septaConnectionMiddleware, favoritesMiddleware, tripDetailMiddleware, pushNotificationsMiddleware]
)

var stateProviders = StateProviders()
var notificationsManager = NotificationsManager()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let databaseUpdateManager = DatabaseUpdateManager()

    var window: UIWindow? {
        didSet {
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Crashlytics.sharedInstance().delegate = self
        Fabric.with([Crashlytics.self, Answers.self])

        stateProviders.preferenceProvider.subscribe()

        databaseUpdateManager.appLaunched(coldStart: true)

        notificationsManager.configure()

        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in })

        application.registerForRemoteNotifications()

        return true
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        let action = ResetModalAlertsDisplayed(modalAlertsDisplayed: true)
        store.dispatch(action)
    }

    func applicationWillEnterForeground(_: UIApplication) {
        databaseUpdateManager.appLaunched(coldStart: false)
        let inAppReview = InAppReview()
        inAppReview.appLaunched()
    }

    func applicationDidBecomeActive(_: UIApplication) {
        let action = ResetModalAlertsDisplayed(modalAlertsDisplayed: false)
        store.dispatch(action)

        updateCurrentPushNotificationAuthorizationStatus()
    }

    func updateCurrentPushNotificationAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status = PushNotificationAuthorizationState(status: settings.authorizationStatus)
            let action = UpdateSystemAuthorizationStatusForPushNotifications(authorizationStatus: status)
            DispatchQueue.main.async {
                store.dispatch(action)
            }
        }
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}

extension AppDelegate: CrashlyticsDelegate {
    func crashlyticsDidDetectReport(forLastExecution _: CLSReport, completionHandler: @escaping (Bool) -> Void) {
        UserDefaults.standard.set(true, forKey: InAppReview.crashReportedKey)
        completionHandler(true)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
}
