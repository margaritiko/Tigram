//
//  CoreDataManagerProtocol.swift
//  Tigram
//
//  Created by Маргарита Коннова on 08/04/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import CoreData

protocol CoreDataManagerProtocol {
    // MARK: Functions
    func performSave(context: NSManagedObjectContext, completionHandler: (() -> Void)?)
    func getContextWith(name: String) -> NSManagedObjectContext?
    func getUserFetchRequest(named name: String, with value: String) -> NSFetchRequest<ChatUser>?
    func getProfileFetchRequest(named name: String, with value: String) -> NSFetchRequest<UserProfileData>?
}
