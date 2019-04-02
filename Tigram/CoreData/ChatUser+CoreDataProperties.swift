//
//  ChatUser+CoreDataProperties.swift
//  Tigram
//
//  Created by Маргарита Коннова on 02/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//
//

import Foundation
import CoreData

extension ChatUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ChatUser> {
        return NSFetchRequest<ChatUser>(entityName: "ChatUser")
    }

    @NSManaged public var isOnline: Bool
    @NSManaged public var name: String?
    @NSManaged public var userId: String?
    @NSManaged public var conversations: Conversation?

}
