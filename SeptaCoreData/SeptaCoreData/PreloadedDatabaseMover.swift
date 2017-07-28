// Septa.org created on 7/28/17.

import Foundation
import Zip

class PreloadedDatabaseMover {
    let bundle = Bundle(for: SetupCoreData.self)
    static let expandedDatabaseName = "SEPTA.sqlite"

    lazy var preloadedZippedDatabaseURL: URL? = {

        bundle.url(forResource: "SEPTA", withExtension: "zip")
    }()

    lazy var cachesDirectoryURL: URL? = {
        let cachesDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        print(cachesDirectoryPath)
        return URL(fileURLWithPath: cachesDirectoryPath)
    }()

    lazy var databaseDestinationURL: URL? = {
        cachesDirectoryURL?.appendingPathComponent(PreloadedDatabaseMover.expandedDatabaseName)
    }()

    func expandZipDatabaseFile() {
        do {
            print("what the fuck")

            try Zip.unzipFile(preloadedZippedDatabaseURL!, destination: cachesDirectoryURL!, overwrite: true, password: nil, progress: nil)
        } catch {
            print("Something went wrong")
        }
    }
}
