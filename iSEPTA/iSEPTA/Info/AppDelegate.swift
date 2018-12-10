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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let databaseUpdateManager = DatabaseUpdateManager()

    var window: UIWindow? {
        didSet {}
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Crashlytics.sharedInstance().delegate = self
        Fabric.with([Crashlytics.self, Answers.self])

        stateProviders.preferenceProvider.subscribe()

        databaseUpdateManager.appLaunched(coldStart: true)

        Messaging.messaging().delegate = self
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        updateCurrentPushNotificationAuthorizationStatus()

        //postFakeNotification()
        return true
    }
    
    func postFakeNotification(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
            let delayNotification = self.buildFakeNotification()
            store.dispatch(AddPushNotificationTripDetailDelayNotification(septaDelayNotification: delayNotification))
        })
    }

    func buildFakeNotification() -> SeptaDelayNotification {
        let url = Bundle.main.url(forResource: "FakeDelayNotification", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let jsonDict = try! JSONSerialization.jsonObject(with: data, options: .allowFragments)

        return SeptaDelayNotification(info: jsonDict as! Payload)!

    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        UIAlert.resetModalAlertsDisplayedFlag(flagMode: true)
    }

    func applicationWillEnterForeground(_: UIApplication) {
        updateCurrentPushNotificationAuthorizationStatus()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // moved from applicationWillEnterForeground so that push notifications are handled first
        databaseUpdateManager.appLaunched(coldStart: false)
        let inAppReview = InAppReview()
        inAppReview.appLaunched()
        
        //UIAlert.resetGenericAlertWasShownFlag(flagMode: false)
        //UIAlert.resetAppAlertWasShownFlag(flagMode: false)
        UIAlert.resetModalAlertsDisplayedFlag(flagMode: false)
    }

    func updateCurrentPushNotificationAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status = PushNotificationAuthorizationState(status: settings.authorizationStatus)
            let action = UpdateSystemAuthorizationStatusForPushNotifications(authorizationStatus: status, fromAppLaunch: true)
            DispatchQueue.main.async {
                store.dispatch(action)
            }
        }
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    private func processNotificationTap(userInfo: [AnyHashable: Any]) {
        // TODO: JJ
        NotificationsManager.handleTap(info: userInfo)
    }
}

extension AppDelegate: CrashlyticsDelegate {
    func crashlyticsDidDetectReport(forLastExecution _: CLSReport, completionHandler: @escaping (Bool) -> Void) {
        UserDefaults.standard.set(true, forKey: InAppReview.crashReportedKey)
        completionHandler(true)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show alert if app is in the foreground
        completionHandler(.alert)
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        DispatchQueue.main.async { [weak self] in
            self?.processNotificationTap(userInfo: userInfo)
        }
        completionHandler()
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String) {
        store.dispatch(SetFirebaseTokenForPushNotificatoins(token: fcmToken, description: "New Firebase token received"))
    }
}
