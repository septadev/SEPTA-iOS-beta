//// Septa.org created on 7/28/17.
//
//import Foundation
//import Zip
//
//class PreloadedDatabaseMover {
//    let importDatabase = ImportDatabase()
//
//    func expandZipDatabaseFile() {
//        do {
//            try Zip.unzipFile(importDatabase.preloadedZippedDatabaseURL!, destination: importDatabase.cachesDirectoryURL!, overwrite: true, password: nil, progress: nil)
//        } catch {
//            print("Something went wrong")
//        }
//    }
//}

