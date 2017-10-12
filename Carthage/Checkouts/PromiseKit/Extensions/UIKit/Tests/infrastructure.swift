import XCTest
import UIKit

extension XCTestCase {
    var rootvc: UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }

    open override func setUp() {
        UIApplication.shared.keyWindow!.rootViewController = UIViewController()
    }

    open override func tearDown() {
        UIApplication.shared.keyWindow!.rootViewController = nil
    }
}
