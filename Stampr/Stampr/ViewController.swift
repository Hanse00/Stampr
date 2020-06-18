//
//  ViewController.swift
//  Stampr
//
//  Created by Philip Mallegol-Hansen on 6/18/20.
//  Copyright © 2020 Philip Mallegol-Hansen. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    var container: NSPersistentContainer!
    
    @IBAction func stampClicked(_ sender: UIButton) {
        let stamp = Stamp(context: container.viewContext)
        stamp.date = Date()
        do {
            try container.viewContext.save()
        } catch {
            fatalError("Unable to save new stamp: \(error)")
        }
        
        printStamps()
    }
    
    @IBAction func printClicked(_ sender: UIButton) {
        printStamps()
    }

    @IBAction func deleteClicked(_ sender: UIButton) {
        let stamps = getSortedStamps()
        guard stamps.count >= 1 else {
            print("Trying to delete from an empty state? Nice try.")
            return
        }
        
        let stamp = stamps[0]
        do {
            container.viewContext.delete(stamp)
            try container.viewContext.save()
            printStamps()
        } catch {
            fatalError("Unable to delete stamp: \(error)")
        }
    }
    
    // MARK: - Utilities
    func printStamps() {
        print(getSortedStamps())
    }
    
    func getSortedStamps() -> [Stamp] {
        let request: NSFetchRequest<Stamp> = Stamp.fetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        request.returnsObjectsAsFaults = false
        do {
            let result = try container.viewContext.fetch(request)
            return result
        } catch {
            fatalError("Unable to load stamps: \(error)")
        }
    }
}

