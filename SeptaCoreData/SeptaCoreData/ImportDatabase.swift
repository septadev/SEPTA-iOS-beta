// SEPTA.org, created on 7/29/17.

import Foundation

class ImportDatabase {
    fileprivate let bundle = Bundle(for: SetupCoreData.self)
    fileprivate let expandedDatabaseName = "SEPTA.sqlite"

    struct TableNames {
        static let stopsRail = "stops_rail"
        static let stopsBus = "stops_bus"
        static let stopTimesRail = "stop_times_rail"
        static let stopTimesBus = "stop_times_bus"
    }

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
