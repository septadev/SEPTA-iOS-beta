//
//  SearchModalHeaderDelegate.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/26/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import UIKit

protocol SearchModalHeaderDelegate {

    func titlesForSegmentedControl() -> [String]

    func delegateForTextField() -> UITextFieldDelegate
    
    func dismiss()
    
    func searchModeDidChange(searchMode: SearchMode)
    
}
