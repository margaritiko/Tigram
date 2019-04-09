//
//  Message+CoreDataClass.swift
//  Tigram
//
//  Created by Маргарита Коннова on 02/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Message)
public class Message: NSManagedObject {
    @nonobjc public class func fetchRequestForConversationWith(userId: String) -> NSFetchRequest<Message> {
        let request = NSFetchRequest<Message>(entityName: "Message")
        request.predicate = NSPredicate(format: "conversation.userId == %@", userId)
        return request
    }
    convenience init(coreDataManager: CoreDataManagerProtocol) {
        let context = coreDataManager.getSaveContext()
        // Entity description
        let entity = NSEntityDescription.entity(forEntityName: "Message", in: context!)

        // Creating new object
        self.init(entity: entity!, insertInto: context)
    }
    static func insertMessage(with coreDataManager: CoreDataManagerProtocol) -> Message? {
        guard let saveContext = coreDataManager.getSaveContext() else {
            assert(false, "Cannot insert new message")
            return nil
        }
        if let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: saveContext) as? Message {
            return message
        }
        return nil
    }
}
