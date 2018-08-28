//
//  GenericAlertDetailProviderFactory.swift
//  iSEPTA
//
//  Created by Mark Broski on 1/27/18.
//  Copyright © 2018 Mark Broski. All rights reserved.
//

import Foundation

class GenericAlertDetailProviderFactory {
    static func generateProvider() -> StateProvider {
        switch SeptaNetwork.sharedInstance.genericAlertEnvironment {
        case .prod: return GenericAlertDetailProvider.sharedInstance
        case .test: return TestGenericAlertDetailProvider.sharedInstance
        }
    }
}
