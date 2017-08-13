// Septa. 2017

import Foundation
import ReSwift

public class StateLogger {
    static let sharedInstance = StateLogger()
    fileprivate let sessionsDirName = "sessions"
    fileprivate let sessionDirName = DateFormatters.fileFormatter.string(from: Date())
    fileprivate let fileManager = FileManager.default
    fileprivate let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()

    fileprivate lazy var documentDirectoryURL: URL? = {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
    }()

    fileprivate lazy var sessionsDirURL: URL? = {
        documentDirectoryURL?.appendingPathComponent(sessionsDirName)
    }()

    fileprivate lazy var sessionDirURL: URL? = {
        sessionsDirURL?.appendingPathComponent(sessionDirName)
    }()

    fileprivate var sessionDirExistsInDocumentsDirectory: Bool {
        guard let url = sessionDirURL else { return false }
        return fileManager.fileExists(atPath: url.path)
    }

    fileprivate func buildFileNameForLogEntry(_ action: SeptaAction) -> String? {
        let actionName = "\(type(of: action))"
        let counterNumber = NSNumber(value: actionCounter)
        guard let counterName = NumberFormatters.logNumberFormatter.string(from: counterNumber) else { return nil }
        let actionCounterName = "\(counterName)-\(actionName).json"
        return actionCounterName
    }

    fileprivate func createSessionDirectory() throws {
        guard let sessionDirURL = sessionDirURL else { return }
        if !sessionDirExistsInDocumentsDirectory {
            try fileManager.createDirectory(at: sessionDirURL, withIntermediateDirectories: true)
        }
    }

    fileprivate func encodeLog(_ actionLog: StateLogEntry) throws -> Data {

        return try encoder.encode(actionLog)
    }

    fileprivate func buildURLForLogFile(fileNameForLogEntry: String) -> URL? {
        return sessionDirURL?.appendingPathComponent(fileNameForLogEntry)
    }

    fileprivate func writeLogToFile(path: String, jsonData: Data) throws {
        if !fileManager.createFile(atPath: path, contents: jsonData) {
            throw LoggingError.couldNotCreateLoggingFile
        }
    }

    fileprivate func logToConsole(_ objects: [Any?]?) {
        guard let objects = objects else { return }
        for obj in objects {
            guard let obj = obj else { continue }
            print(obj)
        }
    }

    func logAction(stateBefore: AppState?, action: Action, stateAfter: AppState, consoleLogObjects: [Any?]? = nil) {
        guard let action = action as? SeptaAction else { return }
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let strongSelf = self else { return }
            let actionLog = StateLogEntry(stateBefore: stateBefore, action: action, stateAfter: stateAfter)
            do {
                try strongSelf.createSessionDirectory()
                if let fileName = strongSelf.buildFileNameForLogEntry(action),
                    let url = strongSelf.buildURLForLogFile(fileNameForLogEntry: fileName) {
                    let jsonData = try strongSelf.encodeLog(actionLog)
                    try strongSelf.writeLogToFile(path: url.path, jsonData: jsonData)
                    strongSelf.actionCounter += 1
                    strongSelf.logToConsole(consoleLogObjects)
                }
            } catch {
                print("Error creating log file \(error.localizedDescription)")
            }
        }
    }

    fileprivate var actionCounter: Int = 0
    private init() {}
}
