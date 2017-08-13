// Septa. 2017

import Foundation

enum LoggingError: Error {
    case missingActionWhileEncoding(String)
    case missingActionWhileDecoding(String)
    case couldNotCreateLoggingFile
}
