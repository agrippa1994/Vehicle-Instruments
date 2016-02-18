//
//  CoreData.swift
//  Vehicle-Instruments
//
//  Created by Manuel Leitold on 18.02.16.
//  Copyright © 2016 mani1337. All rights reserved.
//

import Foundation
import CoreData

class CoreData {
    private static var coreData = CoreData()
    
    lazy var url: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count - 1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let fileUrl = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: fileUrl)!
    }()
    
    lazy var persistanteStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.url.URLByAppendingPathComponent("DataModel.sqlite")
        
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            NSLog("Error while adding persistent store \(error)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = self.persistanteStoreCoordinator
        return managedObjectContext
    }()
    
    class var shared: CoreData {
        return coreData
    }
    
    class func save() -> Bool {
        let ctx = coreData.managedObjectContext
        
        // Save
        if ctx.hasChanges {
            do {
                try ctx.save()
            } catch {
                NSLog("Error while saving in CoreData \(error)")
                return false
            }
        }
        
        return true
    }
    
    class var configurations : [Configuration] {
        let request = NSFetchRequest(entityName: "Configuration")
        let ctx = coreData.managedObjectContext
        guard let data = try? ctx.executeFetchRequest(request) as! [Configuration] else {
            return []
        }
        
        return data
    }

}
