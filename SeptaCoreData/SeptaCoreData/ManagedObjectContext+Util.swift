//
//  ManagedObjectContext+Util.swift
//  SeptaCoreData
//
//  Created by Mark Broski on 7/27/17.
//  Copyright © 2017 Mark Broski. All rights reserved.
//

import CoreData

extension NSManagedObjectContext {
    public func insertObject<A: NSManagedObject>() -> A where A: Managed {
        let entityName = A.entityName
        let obj = NSEntityDescription.insertNewObject(forEntityName: entityName, into: self)
        return obj as! A
    }

    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }

    public func performChanges(block: @escaping () -> Void) {
        perform {
            block()
            _ = self.saveOrRollback()
        }
    }
}
