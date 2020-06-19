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
    lazy var fetchedResultsController: NSFetchedResultsController<Stamp> = {
        let controller = NSFetchedResultsController(fetchRequest: Stamp.sortedFetchRequest(), managedObjectContext: self.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Unable to perform fetch: \(error)")
        }
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
                Stamp.add(to: self.container)
            }
            let printAction = UIAlertAction(title: "Print", style: .default) { (_) in
                print("Stamps as seen by Core Data:")
                print(Stamp.getSortedStampts(from: self.container))
                print("Stamps as seen by NSFetchedResultsController:")
                let stamps = self.fetchedResultsController.fetchedObjects!
                for stamp in stamps {
                    print("\(String(describing: self.fetchedResultsController.indexPath(forObject: stamp))): \(stamp)")
                }
            }
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                Stamp.deleteLatest(from: self.container)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            controller.addAction(addAction)
            controller.addAction(printAction)
            controller.addAction(deleteAction)
            controller.addAction(cancelAction)
            
            present(controller, animated: true)
        }
    }

}


// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Going to change content")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("Inserting \(anObject) to \(newIndexPath!)")
        case .delete:
            print("Deleting \(anObject) from \(indexPath!)")
        case .update:
            print("Updating \(anObject) at \(indexPath!)")
        case .move:
            print("Moving \(anObject) from \(indexPath!) to \(newIndexPath!)")
        @unknown default:
            fatalError("Some other option we weren't aware of")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Done changing content")
    }
}
