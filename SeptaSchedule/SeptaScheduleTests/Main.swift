// Septa. 2017

import Foundation
@testable import SeptaSchedule

class Main: NSObject {
    let fileManager = FileManager.default

    override init() {
        let setup = DatabaseFileManager()

        let testBundle = Bundle(for: Main.self)
        let sourceURL = testBundle.url(forResource: "SEPTA", withExtension: "sqlite")!
        let destinationPath = setup.databaseURL!

        if fileManager.fileExists(atPath: destinationPath.path) {
            try! fileManager.removeItem(atPath: destinationPath.path)
        }

        try! fileManager.copyItem(at: sourceURL, to: destinationPath)
    }
}
