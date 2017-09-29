//
//  File.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/29/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

enum SEPTAWebPage {
    case map
}

class SeptaUrl {
    static let sharedInstanced = SeptaUrl()
    private var urls: SeptaUrls!
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

    func url(forPage url: SEPTAWebPage) -> URL? {
        switch url {
        case .map: return URL(string: urls.map)
        }
    }

    private struct SeptaUrls: Decodable {
        let map: String
    }
}
