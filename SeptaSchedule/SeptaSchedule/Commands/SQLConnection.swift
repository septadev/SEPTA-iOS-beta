// Septa. 2017

import Foundation
import SQLite

class SQLConnection {

    class func sqlConnection() throws -> Connection? {
        let fileManager = DatabaseFileManager()
        _ = try fileManager.unzipFileToDocumentsDirectoryIfNecessary()
        guard let path = fileManager.databaseURL?.path else { return nil }
        return try Connection(path, readonly: true)
    }
}
