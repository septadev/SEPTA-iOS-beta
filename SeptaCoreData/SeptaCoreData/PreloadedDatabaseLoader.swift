//// SEPTA.org, created on 7/29/17.
//
//import Foundation
//import CoreData
//import SQLite
//
//class PreloadedDatabaseLoader {
//    let moc: NSManagedObjectContext
//    let importDatabase = ImportDatabase()
//    let transitTypeRail = "rail"
//    let transitTypeBus = "bus"
//
//    var dbConnection: Connection
//
//    lazy var numberFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
//        return formatter
//    }()
//
//    lazy var percentFormatter: NumberFormatter = {
//        let formatter = NumberFormatter()
//        formatter.numberStyle = .percent
//        return formatter
//    }()
//
//    init?(moc: NSManagedObjectContext) {
//        self.moc = moc
//        moc.undoManager = nil
//        guard let path = importDatabase.databaseDestinationURL?.path else { return nil }
//        do {
//            dbConnection = try Connection(path)
//        } catch {
//            print("Unable to make connection to import database")
//            return nil
//        }
//    }
//
//    func loadTransitModes() {
//
//        guard
//            let railTransitType = TransitType(managedObjectContext: moc),
//            let busTransitType = TransitType(managedObjectContext: moc) else { return }
//
//        railTransitType.name = transitTypeRail
//        busTransitType.name = transitTypeBus
//        loadStops(railTransitType: railTransitType, tableName: ImportDatabase.TableNames.stopsRail, transitType: transitTypeRail)
//        loadStops(railTransitType: busTransitType, tableName: ImportDatabase.TableNames.stopsBus, transitType: transitTypeBus)
//
//        loadStopTimes(tableName: ImportDatabase.TableNames.stopTimesRail)
//        createRelationFromStopTimeToStop()
//        do {
//            try moc.save()
//        } catch {
//            fatalError()
//        }
//    }
//
//    func loadStops(railTransitType _: TransitType, tableName: String, transitType: String) {
//
//        let stopsTable = Table(tableName)
//        let stopIdExpression = Expression<Int?>("stop_id")
//        let nameExpression = Expression<String?>("stop_name")
//        let latExpression = Expression<String?>("stop_lat")
//        let lonExpression = Expression<String?>("stop_lon")
//        let wheelchairBoardingExpression = Expression<Bool?>("wheelchair_boarding")
//
//        do {
//            var i: Double = 0
//            let rowsToProcess: Double = try Double(dbConnection.scalar(stopsTable.count))
//
//            for row in try dbConnection.prepare(stopsTable) {
//                guard let stop = Stop(managedObjectContext: moc) else { fatalError() }
//                if let stopId = row[stopIdExpression],
//                    let name = row[nameExpression],
//                    let lat = row[latExpression],
//                    let lon = row[lonExpression] {
//
//                    stop.stop_id = NSNumber(value: stopId)
//                    stop.name = name
//                    stop.lat = numberFormatter.number(from: lat)
//                    stop.lon = numberFormatter.number(from: lon)
//                    let wheelchairBoarding: Bool = row[wheelchairBoardingExpression] ?? false
//                    stop.wheelchairEnabled = NSNumber(value: wheelchairBoarding)
//                    stop.transitTypeString = transitType
//
//                    i = i + 1
//                    let percentComplete = percentFormatter.string(from: NSNumber(value: i / rowsToProcess))!
//
//                    print("loading \(tableName) \(percentComplete))")
//                }
//
//                if Int(i) % 1000 == 0 {
//                    try moc.save()
//                }
//            }
//
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//
//    func loadStopTimes(tableName: String) {
//
//        let stopTimesTable = Table(tableName)
//        let stopIdExpression = Expression<Int?>("stop_id")
//
//        let tripIdExpression = Expression<String?>("trip_id")
//        let arrivalTimeExpression = Expression<Int?>("arrival_time")
//        let stopSequenceExpression = Expression<Int?>("stop_sequence")
//
//
//        do {
//            var i: Double = 0
//            let rowsToProcess: Double = try Double(dbConnection.scalar(stopTimesTable.count))
//            for row in try dbConnection.prepare(stopTimesTable) {
//
//                guard let stopTime = StopTime(managedObjectContext: moc) else { fatalError() }
//
//                if let stopId = row[stopIdExpression],
//                    let tripId = row[tripIdExpression],
//                    let arrivalTime = row[arrivalTimeExpression],
//                    let stopSequence = row[stopSequenceExpression] {
//                    stopTime.stop_id = NSNumber(value: stopId)
//                    stopTime.trip_id = tripId
//                    stopTime.arrivalTime = NSNumber(value: arrivalTime)
//                    stopTime.stopSequence = NSNumber(value: stopSequence)
//                }
//
//                if Int(i) % 1000 == 0 {
//                    try moc.save()
//                    moc.reset()
//                }
//                i = i + 1
//                let percentComplete = percentFormatter.string(from: NSNumber(value: i / rowsToProcess))!
//
//                print("loading \(tableName) \(percentComplete))")
//            }
//
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//
//    func createRelationFromStopTimeToStop() {
//        let stopFetchRequest = NSFetchRequest<Stop>(entityName: Stop.entityName())
//        stopFetchRequest.propertiesToFetch = [StopAttributes.stop_id.rawValue]
//        do {
//            let stops = try moc.fetch(stopFetchRequest) as [Stop]
//            var i: Double = 0
//
//            for stop in stops {
//                guard let stop_id = stop.stop_id else { continue }
//                let stopTimesFetchRequest = NSFetchRequest<StopTime>(entityName: StopTime.entityName())
//                stopTimesFetchRequest.predicate = NSPredicate(format: "%K == %@", StopTimeAttributes.stop_id.rawValue, stop_id)
//                stopTimesFetchRequest.includesPropertyValues = false
//                let matchingStopTimes = try moc.fetch(stopTimesFetchRequest)
//                let set = NSSet(array: matchingStopTimes)
//                stop.addStopTimes(set)
//
//                i = i + 1
//                let percentComplete = percentFormatter.string(from: NSNumber(value: i / Double(stops.count)))!
//                print("loading stopTimes  \(percentComplete)")
//
//                if Int(i) % 1000 == 0 {
//                    try moc.save()
//                    moc.reset()
//                }
//            }
//            moc.reset()
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//}

