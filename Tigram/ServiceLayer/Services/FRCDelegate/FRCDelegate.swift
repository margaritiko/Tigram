//
//  FRCDelegate.swift
//  Tigram
//
//  Created by Маргарита Коннова on 06/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension NSFetchedResultsControllerDelegate {
    func reinit(tableView: UITableView) {}
}

class FRCDelegate: NSObject, NSFetchedResultsControllerDelegate {
    private var tableView: UITableView?

    func reinit(tableView: UITableView) {
        self.tableView = tableView
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.tableView?.beginUpdates()
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.tableView?.endUpdates()
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        DispatchQueue.main.async {
            switch type {
            case .insert:
                self.tableView?.insertRows(at: [newIndexPath!], with: .automatic)
            case .move:
                self.tableView?.deleteRows(at: [indexPath!], with: .automatic)
                self.tableView?.insertRows(at: [newIndexPath!], with: .automatic)
            case .delete:
                self.tableView?.deleteRows(at: [indexPath!], with: .automatic)
            case .update:
                self.tableView?.reloadRows(at: [indexPath!], with: .automatic)
            }
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        DispatchQueue.main.async {
            switch type {
            case .delete:
                self.tableView?.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
            case .insert:
                self.tableView?.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
            case .move, .update:
                break
            }
        }
    }
}
