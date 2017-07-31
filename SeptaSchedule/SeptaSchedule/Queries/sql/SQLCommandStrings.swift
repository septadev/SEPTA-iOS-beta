// SEPTA.org, created on 7/31/17.

import Foundation

enum SQLFileName: String {
    case busStart
}

class SQLCommandStrings {

    let bundle = Bundle(for: SQLCommandStrings.self)

    func commandStringForFileName(_ fileName: SQLFileName) throws -> String? {
        guard let url = urlForFile(named: fileName.rawValue) else { return nil }
        do {
            return try String(contentsOfFile: url.path)
        } catch {
            return nil
        }
    }

    private func urlForFile(named file: String) -> URL? {
        return bundle.url(forResource: file, withExtension: "sql", subdirectory: nil, localization: nil)
    }
}
