// SEPTA.org, created on 7/29/17.

import Foundation

@testable import SeptaCoreData

class Main: NSObject {
    let fileManager = FileManager.default

    override init() {
        let setup = ImportDatabase()

        let testBundle = Bundle(for: Main.self)
        let sourceURL = testBundle.url(forResource: "SEPTA", withExtension: "sqlite")!
        let destinationPath = setup.databaseDestinationURL!

        if fileManager.fileExists(atPath: destinationPath.path) {
            try! fileManager.removeItem(atPath: destinationPath.path)
        }

        try! fileManager.copyItem(at: sourceURL, to: destinationPath)
    }
}
