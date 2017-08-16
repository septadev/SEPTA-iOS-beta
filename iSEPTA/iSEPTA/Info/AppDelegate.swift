// Septa. 2017

import UIKit
import ReSwift
import SeptaSchedule

import Fabric
import Crashlytics

let store = Store<AppState>(
    reducer: AppStateReducer.mainReducer,
    state: nil,
    middleware: []
)

var stateProviders = StateProviders()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let databaseFileManager = DatabaseFileManager()

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        Fabric.with([Crashlytics.self, Answers.self])

        movePreloadedDatabaseIfNeeded()

        stateProviders.preferenceProvider.subscribe()
        stateProviders.scheduleProvider.subscribe()
        return true
    }

    func movePreloadedDatabaseIfNeeded() {

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                _ = try self.databaseFileManager.unzipFileToDocumentsDirectoryIfNecessary()

            } catch {
                DispatchQueue.main.async {
                    guard let rootviewController = self.window?.rootViewController else { return }
                    Alert.presentOKAlertFrom(viewController: rootviewController,
                                             withTitle: "Database Error",
                                             message: "Could not move the database",
                                             completion: nil)
                }
            }
        }
    }

    func applicationWillResignActive(_: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}
