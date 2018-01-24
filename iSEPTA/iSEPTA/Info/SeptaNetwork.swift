//
//  SeptaNetwork.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/7/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

struct SeptaNetwork {
    let url: String
    let apiKey: String
    let databaseVersion: Int
    let genericAlertName: String
    let appAlertName: String

    private init() {
        let path = Bundle.main.path(forResource: "network", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path)!
        let urlString = dict["url"] as! String
        databaseVersion = dict["databaseVersion"] as! Int
        let apiKey = dict["apiKey"] as! String
        url = urlString
        self.apiKey = apiKey
        genericAlertName = dict["genericAlertName"] as! String
        appAlertName = dict["appAlertName"] as! String
    }

    static let sharedInstance = SeptaNetwork()
}
