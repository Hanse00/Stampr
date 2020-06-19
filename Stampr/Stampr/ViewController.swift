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
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
                let stamp = Stamp(context: self.container.viewContext)
                stamp.date = Date()
                do {
                    try self.container.viewContext.save()
                } catch {
                    fatalError("Unable to save new stamp: \(error)")
                }
                
                self.printStamps()
            }
            let printAction = UIAlertAction(title: "Print", style: .default) { (_) in
                self.printStamps()
            }
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                let stamps = self.getSortedStamps()
                guard stamps.count >= 1 else {
                    print("Trying to delete from an empty state? Nice try.")
                    return
                }
                
                let stamp = stamps[0]
                do {
                    self.container.viewContext.delete(stamp)
                    try self.container.viewContext.save()
                    self.printStamps()
                } catch {
                    fatalError("Unable to delete stamp: \(error)")
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            controller.addAction(addAction)
            controller.addAction(printAction)
            controller.addAction(deleteAction)
            controller.addAction(cancelAction)
            
            present(controller, animated: true)
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

