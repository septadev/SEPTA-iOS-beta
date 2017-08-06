// Septa. 2017

import Foundation

class SQLCommandTemplate {

    let bundle = Bundle(for: BaseCommand.self)

    func commandString(forSQLQuery sqlQuery: SQLQuery) throws -> String? {
        guard let url = urlForFile(named: sqlQuery.fileName) else { return nil }
        do {
            let sqlString = try String(contentsOfFile: url.path)
            return applyBindings(forSQLQuery: sqlQuery, toSQLString: sqlString)
        } catch {
            return nil
        }
    }

    private func applyBindings(forSQLQuery query: SQLQuery, toSQLString sqlString: String) -> String {
        let bindings = query.sqlBindings
        var parameterizedSqlString = sqlString
        for binding in bindings {
            parameterizedSqlString = parameterizedSqlString.replacingOccurrences(of: binding[0], with: binding[1])
        }
        return parameterizedSqlString
    }

    private func urlForFile(named file: String) -> URL? {
        return bundle.url(forResource: file, withExtension: "sql", subdirectory: nil, localization: nil)
    }
}
