//
//  Conversation+CoreDataClass.swift
//  Tigram
//
//  Created by Маргарита Коннова on 02/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Conversation)
public class Conversation: NSManagedObject {
    @nonobjc public class func fetchRequestForUserWith(userId: String) -> NSFetchRequest<Conversation> {
        let request = NSFetchRequest<Conversation>(entityName: "Conversation")
        request.predicate = NSPredicate(format: "%K == %@", "userId", userId)
        return request
    }

    convenience init() {
        let context = CoreDataManager.getInstance().getContextWith(name: "save")
        // Entity description
        let entity = NSEntityDescription.entity(forEntityName: "Conversation", in: context!)

        // Creating new object
        self.init(entity: entity!, insertInto: context)
    }

    static func insertConversation(inContext context: NSManagedObjectContext, forUserWithId userId: String) -> Conversation? {
        if let conversation = NSEntityDescription.insertNewObject(forEntityName: "Conversation", into: context) as? Conversation {
            conversation.userId = userId
            return conversation
        }
        return nil
    }

    static func findOrInsertConversation(inContext context: NSManagedObjectContext, forUserWithId userId: String) -> Conversation? {
        var conversation: Conversation?
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequestForUserWith(userId: userId)

        do {
            let results = try context.fetch(request)
            assert(results.count <= 1, "More than one Multiple Conversations found")
            if let foundConversation = results.first {
                conversation = foundConversation
            }
        } catch {
            assert(false, "Cannot update conversations")
        }

        if conversation == nil {
            conversation = Conversation.insertConversation(inContext: context, forUserWithId: userId)
        }

        return conversation
    }
}
