// SEPTA.org, created on 7/31/17.

import Foundation
import SQLite

class BaseCommand {

    func retrieveResults<T>(fileName: SQLFileName, bindings: [String], userCompletion: @escaping ([T]?, Error?) -> Void, resultsMapper mapper: @escaping (Statement) -> [T]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let strongSelf = self else { return }

            var cmdError: Error?
            var results: [T]?
            do {
                let conn = try strongSelf.getConnection()
                let cmd = try strongSelf.getCommand(fileName: fileName)
                let stmt = try conn.prepare(cmd, bindings)
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

    func getCommand(fileName: SQLFileName) throws -> String {
        let commandStrings = SQLCommandStrings()
        guard let cmd = try commandStrings.commandStringForFileName(fileName) else { throw SQLCommandError.noCommand }
        return cmd
    }
}
