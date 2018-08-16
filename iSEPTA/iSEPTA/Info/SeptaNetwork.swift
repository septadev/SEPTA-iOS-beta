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
    let databaseUpdateDate: Date
    let genericAlertName: String
    let appAlertName: String
    let genericAlertEnvironment: ProviderEnvironment
    let genericAlertTestHost: String
    let genericAlertTestPath: String

    private init() {
        let path = Bundle.main.path(forResource: "network", ofType: "plist")!
        let dict = NSDictionary(contentsOfFile: path)!
        let urlString = Bundle.main.object(forInfoDictionaryKey: "septaUrl") as? String ?? ""
        print(":M: \(urlString)")
        databaseVersion = dict["databaseVersion"] as! Int
        databaseUpdateDate = dict["databaseUpdateDate"] as! Date
        let apiKey = Bundle.main.object(forInfoDictionaryKey: "septaApiKey") as? String ?? ""
        print(":M: \(apiKey)")
        url = urlString
        self.apiKey = apiKey
        genericAlertName = dict["genericAlertName"] as! String
        appAlertName = dict["appAlertName"] as! String
        let genericAlertEnvironmentString = dict["genericAlertEnvironment"] as! String
        if let genericAlertEnvironment = ProviderEnvironment(rawValue: genericAlertEnvironmentString) {
            self.genericAlertEnvironment = genericAlertEnvironment
        } else {
            genericAlertEnvironment = .prod
        }
        genericAlertTestHost = dict["genericAlertTestHost"] as! String
        genericAlertTestPath = dict["genericAlertTestPath"] as! String
    }

    static let sharedInstance = SeptaNetwork()
}
