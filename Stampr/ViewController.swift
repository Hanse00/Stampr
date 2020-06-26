//
//  ViewController.swift
//  Stampr
//
//  Created by Philip Mallegol-Hansen on 6/18/20.
//  Copyright © 2020 Philip Mallegol-Hansen.
//  Availble under the MIT License, see LICENSE for full terms.
//

import UIKit
import CoreData

// MARK: - View Controller
class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
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
        tableView.delegate = self
        tableView.dataSource = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Unable to perform fetch: \(error)")
        }
    }
    
    // MARK: User Interaction
    @IBAction func buttonClicked(_ sender: Any) {
        openButtonUI()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            openButtonUI()
        }
    }
    
    func openButtonUI() {
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
                print("\(self.fetchedResultsController.indexPath(forObject: stamp)!): \(stamp)")
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

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let stamp = fetchedResultsController.object(at: indexPath)
            stamp.delete(from: container)
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StampCell", for: indexPath)
        let stamp = fetchedResultsController.object(at: indexPath)
        
        guard let date = stamp.date else {
            return cell
        }
        
        cell.textLabel?.text = dateFormatter.string(from: date)
        return cell
    }
    
    
}


// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Beginning updates")
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("Inserting: \(newIndexPath!)")
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            print("Updating: \(indexPath!)")
            tableView.reloadRows(at: [indexPath!], with: .automatic)
        case .delete:
            print("Deleting: \(indexPath!)")
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            print("Moving from: \(indexPath!) to \(newIndexPath!)")
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError("Unexpected case for NSFetchedResultsChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("Ending updates")
        tableView.endUpdates()
    }
}
