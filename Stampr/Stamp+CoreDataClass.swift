//
//  Stamp+CoreDataClass.swift
//  Stampr
//
//  Created by Philip Mallegol-Hansen on 6/18/20.
//  Copyright © 2020 Philip Mallegol-Hansen.
//  Availble under the MIT License, see LICENSE for full terms.
//

import Foundation
import CoreData

@objc(Stamp)
public class Stamp: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stamp> {
        return NSFetchRequest<Stamp>(entityName: "Stamp")
    }
    
    @nonobjc public class func sortedFetchRequest() -> NSFetchRequest<Stamp> {
        let request: NSFetchRequest<Stamp> = fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        return request
    }
    
    @nonobjc public class func getSortedStampts(from container: NSPersistentContainer) -> [Stamp] {
        let request = sortedFetchRequest()
        do {
            let result = try container.viewContext.fetch(request)
            return result
        } catch {
            fatalError("Unable to load stamps: \(error)")
        }
    }
    
    @nonobjc public class func add(to container: NSPersistentContainer) {
        container.performBackgroundTask { (context) in
            print("Creating new stamp")
            let stamp = Stamp(context: context)
            stamp.date = Date()
            do {
                try context.save()
                print("Created stamp: \(stamp)")
            } catch {
                fatalError("Unable to save new stamp: \(error)")
            }
        }
    }
    
    @nonobjc public func delete(from container: NSPersistentContainer) {
        container.performBackgroundTask { (context) in
            let stamp = context.object(with: self.objectID)
            print("Deleting stamp: \(stamp)")
            do {
                context.delete(stamp)
                try context.save()
                print("Deleted stamp")
            } catch {
                fatalError("Unable to delete stamp: \(error)")
            }
        }
    }
    
    @nonobjc public class func deleteLatest(from container: NSPersistentContainer) {
        let stamps = getSortedStampts(from: container)
        guard stamps.count >= 1 else {
            print("Trying to delete from an empty array? Nice try.")
            return
        }
        
        stamps[0].delete(from: container)
    }

}
