//
//  StorageManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 25/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager: CoreDataManagerProtocol {

    // MARK: NSPersistentStore
    private var storeURL: URL? {
        guard let documentsDirURL: URL = FileManager.default.urls(for: .documentDirectory,
                                                                  in: .userDomainMask).first else { return nil }
        let url = documentsDirURL.appendingPathComponent("Store.sqlite")
        return url
    }

    // MARK: NSManagedObjectModel
    private let managedObjectModelName: String = "TigramStorage"
    lazy private var managedObjectModel: NSManagedObjectModel? = {
        guard let modelURL = Bundle.main.url(forResource:
            self.managedObjectModelName, withExtension: "momd") else {
                print("Empty model url!")
                return nil
        }
        return NSManagedObjectModel(contentsOf: modelURL)
    }()

    // MARK: NSPersistentStoreCoordinator
    lazy private var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        guard let model = managedObjectModel else {
            print("Empty managed object model!")
            return nil
        }
        var coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                configurationName: nil,
                                                                at: storeURL,
                                                                options: nil)
        } catch {
            assert(false, "Error adding persistent store to coordinator: \(error)")
        }
        return coordinator
    }()

    // MARK: NSManagedObjectContext (Master)
    lazy private var masterContext: NSManagedObjectContext? = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        guard let persistentStoreCoordinator = self.persistentStoreCoordinator else {
            print("Empty persistent store coordinator!")
            return nil
        }
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        context.undoManager = nil
        return context
    }()

    // MARK: NSManagedObjectContext (Main)
    lazy private var mainContext: NSManagedObjectContext? = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        guard let parentContext = self.masterContext else {
            print("No master context!")
            return nil
        }
        context.parent = parentContext
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        context.undoManager = nil
        return context
    }()

    // MARK: NSManagedObjectContext (Save)
    private var saveContext: NSManagedObjectContext? {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        guard let parentContext = self.mainContext else {
            print("No master context!")
            return nil
        }
        context.parent = parentContext
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        context.undoManager = nil
        return context
    }

    // Recursion save
    public func performSave(context: NSManagedObjectContext, completionHandler: (() -> Void)?) {
        context.performAndWait {
            if context.hasChanges {
                context.perform { [weak self] in
                    do {
                        try context.save()
                    } catch {
                        print("Context save error: \(error)")
                    }
                    if let parent = context.parent {
                        self?.performSave(context: parent, completionHandler: completionHandler)
                    } else {
                        completionHandler?()
                    }
                }
            } else {
                completionHandler?()
            }
        }
    }
    // Getting contexts
    public func getSaveContext() -> NSManagedObjectContext? {
        return saveContext
    }
    public func getMainContext() -> NSManagedObjectContext? {
        return mainContext
    }
    // Getting fetch request with given name
    public func getUserFetchRequest(named name: String, with value: String) -> NSFetchRequest<ChatUser>? {
        guard let model = managedObjectModel else {
            return nil
        }
        return model.fetchRequestFromTemplate(withName: name, substitutionVariables: ["ID": value]) as? NSFetchRequest<ChatUser>
    }
    public func getProfileFetchRequest(named name: String, with value: String) -> NSFetchRequest<UserProfileData>? {
        guard let model = managedObjectModel else {
            return nil
        }
        return model.fetchRequestFromTemplate(withName: name, substitutionVariables: ["ID": value]) as? NSFetchRequest<UserProfileData>
    }
}
