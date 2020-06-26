//
//  ViewController.swift
//  Stampr
//
//  Created by Philip Mallegol-Hansen on 6/18/20.
//  Copyright © 2020 Philip Mallegol-Hansen. All rights reserved.
//

import UIKit
import CoreData

enum Section: CaseIterable {
    case main
}

class ViewController: UITableViewController {
    var container: NSPersistentContainer!
    lazy var fetchedResultsController: NSFetchedResultsController<Stamp> = {
        let controller = NSFetchedResultsController(fetchRequest: Stamp.sortedFetchRequest(), managedObjectContext: self.container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()
    lazy var dataSource: UITableViewDiffableDataSource<Section, NSManagedObjectID> = {
        return UITableViewDiffableDataSource(tableView: tableView) {
            (tableView, indexPath, objectID) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "StampCell", for: indexPath)
            
            guard let stamp = self.container.viewContext.object(with: objectID) as? Stamp, let date = stamp.date else {
                return cell
            }
            
            cell.textLabel?.text = self.dateFormatter.string(from: date)
            return cell
        }
    }()
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = dataSource
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeContentWith snapshot: NSDiffableDataSourceSnapshotReference) {
        print("Applying snapshot to datasource")
        dataSource.apply(snapshot as NSDiffableDataSourceSnapshot<Section, NSManagedObjectID>)
    }
}
