//
//  StorageManager.swift
//  Tigram
//
//  Created by Маргарита Коннова on 25/03/2019.
//  Copyright © 2019 Margarita Konnova. All rights reserved.
//

import Foundation
import CoreData

class StorageManager {
    
    static let mainInstance = StorageManager()
    
    // MARK: Life Cycle
    
    private init() {}
    
    // MARK: NSPersistentStore
    
    private var storeURL: URL? {
        get {
            guard let documentsDirURL: URL = FileManager.default.urls(for: .documentDirectory,
                                                                 in: .userDomainMask).first else  { return nil }
            let url = documentsDirURL.appendingPathComponent("Store.sqlite")
            return url
        }
    }
    
    // MARK: NSManagedObjectModel
    
    private let managedObjectModelName: String = "TigramStorage"
    private var _managedObjectModel: NSManagedObjectModel?
    private var managedObjectModel: NSManagedObjectModel? {
        get {
            if _managedObjectModel == nil {
                guard let modelURL = Bundle.main.url(forResource:
                    self.managedObjectModelName, withExtension: "momd") else {
                    print("Empty model url!")
                    return nil
                }
                
                _managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
            }
            return _managedObjectModel
        }
    }
    
    // MARK: NSPersistentStoreCoordinator
    
    private var _persistentStoreCoordinator: NSPersistentStoreCoordinator?
    private var persistentStoreCoordinator: NSPersistentStoreCoordinator? {
        get {
            if _persistentStoreCoordinator == nil {
                guard let model = self.managedObjectModel else {
                    print("Empty managed object model!")
                    return nil
                }
                
                _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
                
                do {
                    try _persistentStoreCoordinator?.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                        configurationName: nil,
                                                                        at: storeURL,
                                                                        options: nil)
                } catch {
                    assert(false, "Error adding persistent store to coordinator: \(error)")
                }
            }
            
            return _persistentStoreCoordinator
        }
    }
    
    // MARK: NSManagedObjectContext (Master)
    
    private var _masterContext: NSManagedObjectContext?
    private var masterContext: NSManagedObjectContext? {
        get {
            if _masterContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                
                guard let persistentStoreCoordinator = self.persistentStoreCoordinator else {
                    print("Empty persistent store coordinator!")
                    
                    return nil
                }
                
                context.persistentStoreCoordinator = persistentStoreCoordinator
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _masterContext = context
            }
            
            return _masterContext
        }
    }
    
    // MARK: NSManagedObjectContext (Main)
    
    private var _mainContext: NSManagedObjectContext?
    private var mainContext: NSManagedObjectContext? {
        get {
            if _mainContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
                
                guard let parentContext = self.masterContext else {
                    print("No master context!")
                    return nil
                }
                
                context.parent = parentContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _mainContext = context
            }
            
            return _mainContext
        }
    }
    
    // MARK: NSManagedObjectContext (Save)
    
    private var _saveContext: NSManagedObjectContext?
    private var saveContext: NSManagedObjectContext? {
        get {
            if _saveContext == nil {
                let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
                guard let parentContext = self.mainContext else {
                    print("No master context!")
                    return nil
                }
                
                context.parent = parentContext
                context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
                context.undoManager = nil
                _saveContext = context
            }
            
            return _saveContext
        }
    }
    
    // Recursion save
    public func perfomSave(context: NSManagedObjectContext, completionHandler: (() -> Void)?) {
        context.performAndWait {
            if context.hasChanges {
                context.perform { [weak self] in
                    do {
                        try context.save()
                    }
                    catch {
                        print("Context save error: \(error)")
                    }
                    
                    if let parent = context.parent {
                        self?.perfomSave(context: parent, completionHandler: completionHandler)
                    }
                    else {
                        completionHandler?()
                    }
                }
            }
            else {
                completionHandler?()
            }
        }
    }
    
    // Getting context with given name
    public func getContextWith(name: String) -> NSManagedObjectContext? {
        if (name == "master") {
            return masterContext
        }
        if (name == "main") {
            return mainContext
        }
        return saveContext
    }
}