//
//  DatabaseVersionSQLCommand.swift
//  SeptaSchedule
//
//  Created by Mike Mannix on 6/20/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

public typealias DatabaseVersionCommandCompletion = ([Int]?, Error?) -> Void

public class DatabaseVersionSQLCommand: BaseCommand {
    public static let sharedInstance = DatabaseVersionSQLCommand()
    
    private override init() {}
    
    public func version(completion: @escaping DatabaseVersionCommandCompletion) {
        let sqlQuery = DatabaseVersionSQLQuery()
        self.retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [Int] in
            var versions = [Int]()
            for row in statement {
                if
                    let col0 = row[0],
                    let versionString = col0 as? String,
                    let versionInt = Int(versionString)
                {
                    versions.append(versionInt)
                }
            }
            return versions
        }
    }
}
