// SEPTA.org, created on 7/29/17.

import Foundation
import CoreData
import SQLite

class PreloadedDatabaseLoader {
    let moc: NSManagedObjectContext

    lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()

    init(moc: NSManagedObjectContext) {
        self.moc = moc
    }

    func loadRailStops() {
        let importDatabase = ImportDatabase()
        guard let path = importDatabase.databaseDestinationURL?.path else { return }

        let railStopsTable = Table("stops_rail")
        let stopIdExpression = Expression<Int?>("stop_id")
        let nameExpression = Expression<String?>("stop_name")
        let latExpressino = Expression<String?>("stop_lat")
        let lonExpression = Expression<String?>("stop_lon")
        let wheelchairBoardingExpression = Expression<Int64?>("wheelchair_boarding")

        do {

            let db = try Connection(path)

            for row in try db.prepare(railStopsTable) {
                guard let stop = Stop(managedObjectContext: moc) else { fatalError() }
                guard let stopId = row[stopIdExpression],
                    let name = row[nameExpression],
                    let lat = row[latExpressino],
                    let lon = row[lonExpression] else { return }
                stop.stop_id = NSNumber(value: stopId)
                stop.name = name
                stop.lat = numberFormatter.number(from: lat)
                stop.lon = numberFormatter.number(from: lon)
                let wheelchairBoarding: Int64 = row[wheelchairBoardingExpression] ?? 0
                stop.wheelchairEnabled = NSNumber(value: wheelchairBoarding > 0)
            }
            try moc.save()

        } catch {
            print(error.localizedDescription)
        }
    }
}
