import PMKAssetsLibrary
import AssetsLibrary
import PromiseKit
import UIKit

@UIApplicationMain
class App: UITableViewController, UIApplicationDelegate {

    var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)
    let testSuceededSwitch = UISwitch()

    func application(_: UIApplication, willFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]? = nil) -> Bool {
        window!.rootViewController = self
        window!.backgroundColor = UIColor.purple
        window!.makeKeyAndVisible()
        UIView.setAnimationsEnabled(false)
        return true
    }

    override func viewDidLoad() {
        view.addSubview(testSuceededSwitch)
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    override func tableView(_: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "1"
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        _ = promise(UIImagePickerController()).then { (_: NSData) in
            self.testSuceededSwitch.isOn = true
        }
    }
}
