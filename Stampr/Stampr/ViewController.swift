//
//  ViewController.swift
//  Stampr
//
//  Created by Philip Mallegol-Hansen on 6/18/20.
//  Copyright © 2020 Philip Mallegol-Hansen. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController {
    var container: NSPersistentContainer!
    lazy var fetchedResultsController: NSFetchedResultsController<Stamp> = {
        let controller = NSFetchedResultsController(fetchRequest: Stamp.sortedFetchRequest(), managedObjectContext: self.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Unable to perform fetch: \(error)")
        }
    }
    
    // MARK: User Interaction
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

// MARK: - UITableViewController
extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StampCell", for: indexPath)
        let note = fetchedResultsController.object(at: indexPath)
        guard let date = note.date else {
            return cell
        }
        
        cell.textLabel?.text = dateFormatter.string(from: date)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let stamp = fetchedResultsController.object(at: indexPath)
            print("Swiped to delete \(stamp) from \(indexPath)")
            stamp.delete()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            print("Deleting \(anObject) from \(indexPath!)")
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            print("Updating \(anObject) at \(indexPath!)")
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            print("Moving \(anObject) from \(indexPath!) to \(newIndexPath!)")
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError("Some other option we weren't aware of")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Done changing content")
    }
}
