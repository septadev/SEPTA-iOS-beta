//
//  MapFromAlerts.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule
import SeptaRest

protocol MappableAlert {
    var route_id: String? { get }
    var mode: String? { get }
}

extension Alert: MappableAlert {}

class MapFromAlerts {
    private var mappingDictionary: [String: [String: [String: Any?]]]?
    let transitModesKey = "transitModes"
    let dbRouteIdKey = "dbRouteId"
    fileprivate lazy var mapFromAlertsUrl: URL? = {
        Bundle.main.url(forResource: "WebAlertsRoutesMappedToDBRoutes", withExtension: "json")
    }()

    static let sharedInstance = MapFromAlerts()

    struct MappingObject: Decodable {
    }

    private init() {
        loadMappingDictionary()
    }

    func loadMappingDictionary() {
        guard let mapFromAlertsUrl = mapFromAlertsUrl else { return }
        do {
            let jsonData = try Data(contentsOf: mapFromAlertsUrl)
            mappingDictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: [String: [String: Any?]]]

        } catch {
            print(error.localizedDescription)
        }
    }

    func mapAlert(mappableAlert: MappableAlert) -> [QuickMap]? {
        guard let mappingDictionary = mappingDictionary,
            let mode = mappableAlert.mode,
            let route_id = mappableAlert.route_id else { return nil }

        guard let modeDict = mappingDictionary[mode],
            let routeDict = modeDict[route_id],
            let routeId = routeDict[dbRouteIdKey] as? String,
            let transitModeInts = routeDict[transitModesKey] as? [Int] else { return nil }

        let transitModes = transitModeInts.map({ TransitMode(rawValue: $0) }).flatMap { $0 }

        return transitModes.map {
            QuickMap(transitMode: $0, routeId: routeId)
        }
    }
}
