//
//  MapToAlerts.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/17/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import SeptaSchedule

class MapToAlerts {
    private var mappingDictionary: [String: [String: String]]?

    fileprivate lazy var mapToAlertsUrl: URL? = {
        Bundle.main.url(forResource: "DbAlertsMappedToWebAlerts", withExtension: "json")
    }()

    static let sharedInstance = MapToAlerts()

    private init() {
        loadMappingDictionary()
    }

    func loadMappingDictionary() {
        guard let mapToAlertsUrl = mapToAlertsUrl else { return }
        do {
            let jsonData = try Data(contentsOf: mapToAlertsUrl)
            mappingDictionary = try JSONDecoder().decode([String: [String: String]].self, from: jsonData)

        } catch {
            print(error.localizedDescription)
        }
    }

    func alertRouteId(forTransitMode transitMode: TransitMode, dbRouteId: String) -> String? {
        guard let mappingDictionary = mappingDictionary else { return nil }
        let stringTransitMode = String(transitMode.rawValue)
        return mappingDictionary[stringTransitMode]?[dbRouteId]
    }
}
