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
    case fares
    case septaKey
    case passPerks
}

class SeptaWebUrlManager {
    static let sharedInstance = SeptaWebUrlManager()
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

    func info(forPage page: SEPTAWebPage) -> SeptaUrlInfo? {
        guard let url = url(forPage: page) else { return nil }
        return SeptaUrlInfo(url: url, title: title(forPage: page))
    }

    private func url(forPage url: SEPTAWebPage) -> URL? {
        var urlString: String?
        switch url {
        case .map: urlString = urls.map
        case .fares: urlString = urls.fares
        case .septaKey: urlString = urls.septaKey
        case .passPerks: urlString = urls.passPerks
        }
        guard let string = urlString else { return nil }
        return URL(string: string)
    }

    private func title(forPage url: SEPTAWebPage) -> String {
        switch url {
        case .map: return "SEPTA Map"
        case .fares: return "More Fares Information"
        case .septaKey: return "SEPTA Key"
        case .passPerks: return "PASS Perks"
        }
    }

    private struct SeptaUrls: Decodable {
        let map: String
        let fares: String
        let septaKey: String
        let passPerks: String
    }
}
