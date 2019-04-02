//
//  MessagesFetchedResultsControllerManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 02/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import CoreData

class MessagesFetchedResultsControllerManager: NSObject {
    lazy var context = CoreDataManager.instance.getContextWith(name: "save")
    var fetchedResultsController: NSFetchedResultsController<Message>?
    var tableView: UITableView?

    func startFollowingChanges(for tableView: UITableView, with userId: String?) {
        guard let saveContext = context else {
            return
        }
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "conversation.userId == %@", userId ?? "emptyUserID")
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
        ]
        fetchedResultsController = NSFetchedResultsController<Message>(fetchRequest: request, managedObjectContext: saveContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self as NSFetchedResultsControllerDelegate
        do {
            try self.fetchedResultsController?.performFetch()
        } catch let error as NSError {
            print("ERROR: \(error.description)")
        }
    }
}
extension MessagesFetchedResultsControllerManager: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView?.insertRows(at: [newIndexPath!], with: .automatic)
        case .move:
            tableView?.deleteRows(at: [indexPath!], with: .automatic)
            tableView?.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView?.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView?.reloadRows(at: [indexPath!], with: .automatic)
        }
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            tableView?.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .insert:
            tableView?.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .move, .update:
            break
        }
    }
}
