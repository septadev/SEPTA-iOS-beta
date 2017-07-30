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

    func loadTransitModes(){

        guard
            let railTransitType = TransitType(managedObjectContext: moc),
            let busTransitType = TransitType(managedObjectContext: moc) else {return }

        railTransitType.name = "Rail"
        busTransitType.name = "Bus"
        loadStops(railTransitType:railTransitType, tableName: ImportDatabase.TableNames.stopsRail)
        loadStops(railTransitType:busTransitType, tableName: ImportDatabase.TableNames.stopsBus)

        do {
            try moc.save()
        }
        catch {
            fatalError()
        }
    }

    func loadStops(railTransitType: TransitType, tableName: String) {
        let importDatabase = ImportDatabase()
        guard let path = importDatabase.databaseDestinationURL?.path else { return }

        let stopsTable = Table(tableName)
        let stopIdExpression = Expression<Int?>("stop_id")
        let nameExpression = Expression<String?>("stop_name")
        let latExpressino = Expression<String?>("stop_lat")
        let lonExpression = Expression<String?>("stop_lon")
        let wheelchairBoardingExpression = Expression<Bool?>("wheelchair_boarding")

        do {

            let db = try Connection(path)
            var i = 1;
            for row in try db.prepare(stopsTable) {
                guard let stop = Stop(managedObjectContext: moc) else { fatalError() }
                guard let stopId = row[stopIdExpression],
                    let name = row[nameExpression],
                    let lat = row[latExpressino],
                    let lon = row[lonExpression] else { fatalError()  }
                stop.stop_id = NSNumber(value: stopId)
                stop.name = name
                stop.lat = numberFormatter.number(from: lat)
                stop.lon = numberFormatter.number(from: lon)
                let wheelchairBoarding: Bool = row[wheelchairBoardingExpression] ?? false
                stop.wheelchairEnabled = NSNumber(value: wheelchairBoarding)

                railTransitType.addStopsObject(stop)
                print ("Adding stops Object for \(tableName) \(i)")
                i = i + 1
            }


        } catch {
            print(error.localizedDescription)
        }
    }


}
