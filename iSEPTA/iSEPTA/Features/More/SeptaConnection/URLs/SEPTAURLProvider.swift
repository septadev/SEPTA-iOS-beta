//
//  File.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

class SEPTAUrlProvider {
    static let sharedInstance = SEPTAUrlProvider()
    var urls: SeptaUrls!
    private init() {
        if let fileURL = Bundle.main.url(forResource: "url", withExtension: "plist") {
            do {
                let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
                let decoder = PropertyListDecoder()
                urls = try decoder.decode(SeptaUrls.self, from: data)

            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
