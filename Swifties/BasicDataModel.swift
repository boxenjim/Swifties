//
//  BasicDataModel.swift
//  Swifties
//
//  Created by Jim Schultz on 2/11/15.
//  Copyright (c) 2015 Blue Boxen, LLC. All rights reserved.
//

import Foundation
import CoreData

public class BasicDataModel: NSObject {
    
    private var dataStoreType: String?
    private var dataModelName: String?
    
    convenience init(storeType: String?, modelName: String?) {
        self.init()
        dataStoreType = storeType
        dataModelName = modelName
    }
    
    lazy var storeType: String = {
        if let type = self.dataStoreType { return type }
        return NSSQLiteStoreType
        }()
    
    // MARK: - Filesystem hooks
    lazy var modelName: String = {
        if let name = self.dataModelName { return name }
        return NSBundle.mainBundle().bundleIdentifier!.pathExtension
        }()
    
    lazy var modelURL: NSURL = {
        let filename: String = self.modelName
        let modelURL = NSBundle.mainBundle().URLForResource(filename, withExtension: "momd")!
        return modelURL
    }()
    
    lazy var storeFileName: String = {
        let modelName: NSString = self.modelName as NSString
        return modelName.stringByAppendingPathExtension("sqlite")!
    }()
    
    lazy var localStoreURL: NSURL = {
        let storeName = self.storeFileName
        let docURL = self.applicationDocumentsDirectory
        return docURL.URLByAppendingPathComponent(storeName)
    }()
    
    lazy var defaultStoreURL: NSURL = {
        let storeName = self.storeFileName
        let storeURL = NSBundle.mainBundle().URLForResource(storeName, withExtension: nil)!
        return storeURL
    }()
    
    public lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()
    
    // MARK: - Core Data stack
    
    public func preinstallDefaultDatabase() {
        let noLocalDBExists = !NSFileManager.defaultManager().fileExistsAtPath(self.localStoreURL.absoluteString!)
        let noDefaultDBExists = !NSFileManager.defaultManager().fileExistsAtPath(self.defaultStoreURL.absoluteString!)
        var error: NSError? = nil
        if noLocalDBExists && noDefaultDBExists {
            if !NSFileManager.defaultManager().copyItemAtURL(self.defaultStoreURL, toURL: self.localStoreURL, error: &error) {
                println("Error copying default DB to \(self.localStoreURL) (\(error))")
            }
        }
    }
    
    public lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel(contentsOfURL: self.modelURL)!
    }()
    
    public lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true]
        if coordinator!.addPersistentStoreWithType(self.storeType, configuration: nil, URL: self.localStoreURL, options: options, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    public lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    public func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
}
