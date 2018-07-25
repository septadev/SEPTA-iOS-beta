//
//  TransitViewService.swift
//  iSEPTA
//
//  Created by Mike Mannix on 7/25/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import SeptaRest

class TransitViewService {
    let network = SeptaNetwork.sharedInstance

    func transitViewDataTask(for routeIds: [String], completion: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) -> URLSessionDataTask {
        let urlString = urlWithRouteIds(routeIds: routeIds)
        guard let url = URL(string: urlString) else { return URLSessionDataTask() }
        var request = URLRequest(url: url)
        request.setValue(network.apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return URLSession.shared.dataTask(with: request, completionHandler: completion)
    }

    private func urlWithRouteIds(routeIds: [String]) -> String {
        var url = "\(network.url)/transitviewall?routes="
        for route in routeIds {
            url.append("\(route),")
        }
        url.removeLast() // remove last comma
        return url
    }
}
