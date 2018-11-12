//
//  AppState.swift
//  iSEPTATests
//
//  Created by James Johnson on 11/09/2018.
//  Copyright © 2018 CapTech Consulting. All rights reserved.
//

import XCTest
import ReSwift
@testable import Septa

class AppStateReducerTests: XCTestCase {

    override func setUp() {
        
        let store = Store<AppState>(
            reducer: AppStateReducer.mainReducer,
            state: nil,
            middleware: [loggingMiddleware, nextToArriveMiddleware, septaConnectionMiddleware, favoritesMiddleware, tripDetailMiddleware, pushNotificationsMiddleware]
        )
        
        var stateProviders = StateProviders()
        stateProviders.preferenceProvider.subscribe()
        
    }
    
    override func tearDown() {
        
    }
    
    /// Does the main reducer return a state
    func testDoesTheMainReducerReturnAState() {
        //let action = TransitModeSelected(transitMode: .bus, description: "Just picked a transit Mode")
        //let state = AppStateReducer.mainReducer(action: action, state: nil)
        //XCTAssertNotNil(state)
    }
    
}
