//
//  ChatUser+CoreDataClass.swift
//  Tigram
//
//  Created by Маргарита Коннова on 02/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ChatUser)
public class ChatUser: NSManagedObject {
    // MARK: CoreData
    // Forming a query from the query pattern
    static func getFetchRequest() -> NSFetchRequest<ChatUser> {
        let fetchRequest = NSFetchRequest<ChatUser>(entityName: "ChatUser")
        return fetchRequest
    }
    // Creating default data for empty user
    static func insertNewUser(in context: NSManagedObjectContext) -> ChatUser? {
        if let chatUser = NSEntityDescription.insertNewObject(forEntityName: "ChatUser", into: context) as? ChatUser {
            chatUser.name = "Margarita Konnova"
            return chatUser
        }
        return nil
    }
    // In order to get an object from the repository, we should execute a query to it.

    static func findOrInsertUser(in context: NSManagedObjectContext, userId: String? = nil, with coreDataManager: CoreDataManagerProtocol) -> ChatUser? {
        var user: ChatUser?
        var fetchRequest: NSFetchRequest<ChatUser>
        if let userId = userId, let request = coreDataManager.getUserFetchRequest(named: "UserWithId", with: userId) {
            fetchRequest = request
        } else {
            fetchRequest = ChatUser.getFetchRequest()
        }
        // Waiting for finish
        context.performAndWait {
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 1 {
                    if let foundUser = results.last {
                        user = foundUser
                    }
                } else {
                    if let foundUser = results.first {
                        user = foundUser
                    }
                }

            } catch {
                print("Failed to fetch ChatUser: \(error)")
            }
        }
        if user == nil {
            user = ChatUser.insertNewUser(in: context)
        }
        return user
    }
}
