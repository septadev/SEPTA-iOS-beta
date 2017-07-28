//
//  TransitType.swift
//  SeptaCoreData
//
//  Created by Mark Broski on 7/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import CoreData

@objc(TransitType)
public final class TransitType: NSManagedObject, Managed {
    @NSManaged fileprivate(set) var name: String

    public static var defaultSortDescriptors: [NSSortDescriptor] { return [NSSortDescriptor]() }
    public static var entityName = "TransitType"

    public static func insert(intoContext moc: NSManagedObjectContext, name: String) -> TransitType {
        let transitType: TransitType = moc.insertObject()
        transitType.name = name
        return transitType
    }
}
