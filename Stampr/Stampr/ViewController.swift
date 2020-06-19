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
                Stamp.add(to: self.container)
                print(Stamp.getSortedStampts(from: self.container))
            }
            let printAction = UIAlertAction(title: "Print", style: .default) { (_) in
                print(Stamp.getSortedStampts(from: self.container))
            }
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                Stamp.deleteLatest(from: self.container)
                print(Stamp.getSortedStampts(from: self.container))
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

