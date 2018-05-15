// Septa. 2017

import Foundation
import SQLite

public class BaseCommand {

    func retrieveResults<T>(sqlQuery: SQLQueryProtocol, userCompletion: @escaping ([T]?, Error?) -> Void, resultsMapper mapper: @escaping (Statement) -> [T]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }

            var cmdError: Error?
            var results: [T]?
            do {
                let conn = try strongSelf.getConnection()
                let commandString = try strongSelf.getCommandString(forSqlQuery: sqlQuery)
                print(commandString)
                let stmt = try conn.prepare(commandString)
                results = mapper(stmt)
            } catch {
                cmdError = error
            }

            DispatchQueue.main.async {
                userCompletion(results, cmdError)
            }
    } }

    func getConnection() throws -> Connection {
        guard let conn = try SQLConnection.sqlConnection() else { throw SQLCommandError.noConnection }
        return conn
    }

    func getCommandString(forSqlQuery sqlQuery: SQLQueryProtocol) throws -> String {
        let template = SQLCommandTemplate()
        guard let cmd = try template.commandString(forSQLQuery: sqlQuery) else { throw SQLCommandError.noCommand }
        return cmd
    }
}
