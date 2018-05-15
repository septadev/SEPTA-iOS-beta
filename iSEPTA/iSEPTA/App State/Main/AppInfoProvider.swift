//
//  AppInfoProvider.swift
//  iSEPTA
//
//  Created by Mark Broski on 10/8/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
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

    private static func valueForKey<T>(_ key: String) -> T {
        return Bundle.main.object(forInfoDictionaryKey: key) as! T
    }
}
