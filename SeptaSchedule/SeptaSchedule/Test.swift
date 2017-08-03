//
//  Test.swift
//  SeptaSchedule
//
//  Created by Mark Broski on 8/3/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation
import Regex

public class Test {

    public  init(){}

    public func replaceString(string text: String) -> String?{
        let regex = Regex("Mark")
        return regex.firstMatch(in: text)?.matchedString

   }
}
