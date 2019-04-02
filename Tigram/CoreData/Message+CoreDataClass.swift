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
    convenience init() {
        let context = CoreDataManager.instance.getContextWith(name: "save")
        // Entity description
        let entity = NSEntityDescription.entity(forEntityName: "Message", in: context!)

        // Creating new object
        self.init(entity: entity!, insertInto: context)
    }
    static func insertMessage() -> Message? {
        guard let saveContext = CoreDataManager.instance.getContextWith(name: "save") else {
            assert(false, "Cannot insert new message")
            return nil
        }
        if let message = NSEntityDescription.insertNewObject(forEntityName: "Message", into: saveContext) as? Message {
            return message
        }
        return nil
    }
}
