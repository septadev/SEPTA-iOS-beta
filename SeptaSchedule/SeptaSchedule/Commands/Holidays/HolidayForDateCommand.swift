//
//  HolidayForDateCommand.swift
//  SeptaSchedule
//
//  Created by James Johnson on 01/07/2019.
//  Copyright © 2019 Mark Broski. All rights reserved.
//

import Foundation

public class HolidayForDateCommand: BaseCommand {
    public typealias HolidayForDateCommandCompletion = ([String]?, Error?) -> Void
    public static let sharedInstance = HolidayForDateCommand()

    public override init() {}
    
    public func holidays(forTransitMode transitMode: TransitMode, completion: @escaping HolidayForDateCommandCompletion) {
        let sqlQuery = HolidayForDateSQLQuery(transitMode: transitMode)
        retrieveResults(sqlQuery: sqlQuery, userCompletion: completion) { (statement) -> [String] in
            var holidayMode = [String]()
            for row in statement {
                if let holidayString = row[0] as? String {
                    holidayMode.append(holidayString)
                }
            }
            return holidayMode
        }
    }
    
}
