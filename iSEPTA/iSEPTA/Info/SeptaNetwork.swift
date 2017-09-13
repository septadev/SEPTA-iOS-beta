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

    private init() {
        let path = Bundle.main.path(forResource: "network", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path)!
        let urlString = dict["url"] as! String
        databaseVersion = dict["databaseVersion"] as! Int
        let apiKey = dict["apiKey"] as! String
        url = urlString
        self.apiKey = apiKey
    }

    static let sharedInstance = SeptaNetwork()
}
