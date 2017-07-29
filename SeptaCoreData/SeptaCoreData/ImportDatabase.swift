// SEPTA.org, created on 7/29/17.

import Foundation

class ImportDatabase {
    fileprivate let bundle = Bundle(for: SetupCoreData.self)
    fileprivate let expandedDatabaseName = "SEPTA.sqlite"

    lazy var preloadedZippedDatabaseURL: URL? = {

        bundle.url(forResource: "SEPTA", withExtension: "zip")
    }()

    lazy var cachesDirectoryURL: URL? = {
        let cachesDirectoryPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        print(cachesDirectoryPath)
        return URL(fileURLWithPath: cachesDirectoryPath)
    }()

    lazy var databaseDestinationURL: URL? = {
        cachesDirectoryURL?.appendingPathComponent(expandedDatabaseName)
    }()
}
