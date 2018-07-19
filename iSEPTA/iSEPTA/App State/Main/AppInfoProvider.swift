//
//  AppInfoProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

class AppInfoProvider {

    static func buildNumber() -> String {
        return valueForKey("CFBundleVersion")
    }

    static func versionNumber() -> String {
        return valueForKey("CFBundleShortVersionString")
    }

    static func lastDatabaseUpdate() -> Date {
        return valueForKey("lastDatabaseUpdate")
    }
    
    static func databaseVersionNumber() -> String {
        let dbFileManager = DatabaseFileManager()
        return String(dbFileManager.currentDatabaseVersion())
    }
    
    static func databaseUpdateDate() -> String {
        let dbFileManager = DatabaseFileManager()
        let updateDate = dbFileManager.databaseUpdateDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ssZZZZZ"
        if let formattedDate = formatter.date(from: updateDate) {
            formatter.dateFormat = "MM/dd/yyyy"
            return formatter.string(from: formattedDate)
        }
        return updateDate
    }

    private static func valueForKey<T>(_ key: String) -> T {
        return Bundle.main.object(forInfoDictionaryKey: key) as! T
    }
}
