//
//  LoggingError.swift
//  iSEPTA
//
//  Created by Mark Broski on 8/12/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import Foundation

enum LoggingError: Error {
    case missingActionWhileEncoding(String)
    case missingActionWhileDecoding(String)
    case couldNotCreateLoggingFile
}
