//
//  Stamp+CoreDataProperties.swift
//  Stampr
//
//  Created by Philip Mallegol-Hansen on 6/18/20.
//  Copyright © 2020 Philip Mallegol-Hansen. All rights reserved.
//
//

import Foundation
import CoreData


extension Stamp {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stamp> {
        return NSFetchRequest<Stamp>(entityName: "Stamp")
    }

    @NSManaged public var date: Date?

}
