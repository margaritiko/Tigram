//
//  Message+CoreDataProperties.swift
//  Tigram
//
//  Created by Маргарита Коннова on 02/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//
//

import Foundation
import CoreData

extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var isIncoming: Bool
    @NSManaged public var text: String?
    @NSManaged public var conversation: Conversation?
    @NSManaged public var conversationWhereLast: Conversation?

}
