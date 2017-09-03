//
//  AddressReducer.swift
//  iSEPTA
//
//  Created by Mark Broski on 9/2/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import ReSwift
import CoreLocation

struct AddressLookupReducer {

    static func main(action: Action, state: AddressLookupState?) -> AddressLookupState {
        if let state = state {
            guard let action = action as? AddressLookupAction else { return state }
            return reduceAddressLookupActions(action: action, state: state)
        } else {
            return AddressLookupState()
        }
    }

    static func reduceAddressLookupActions(action: AddressLookupAction, state: AddressLookupState) -> AddressLookupState {
        var addressLookup = state
        switch action {
        case let action as LookupAddressRequest:
            addressLookup = reduceLookupAddressRequest(action: action, state: state)
        case let action as LoadLookupAddresses:
            addressLookup = reduceLoadLookupAddresses(action: action, state: state)
        case let action as ClearLookupAddresses:
            addressLookup = reduceClearLookupAddresses(action: action, state: state)
        default:
            break
        }

        return addressLookup
    }

    static func reduceLookupAddressRequest(action: LookupAddressRequest, state: AddressLookupState) -> AddressLookupState {
        return AddressLookupState(searchString: action.searchString, searchResults: state.searchResults)
    }

    static func reduceLoadLookupAddresses(action: LoadLookupAddresses, state: AddressLookupState) -> AddressLookupState {
        return AddressLookupState(searchString: state.searchString, searchResults: action.searchResults, error: action.error)
    }

    static func reduceClearLookupAddresses(action _: ClearLookupAddresses, state _: AddressLookupState) -> AddressLookupState {
        return AddressLookupState(searchString: "", searchResults: [CLPlacemark]())
    }
}
