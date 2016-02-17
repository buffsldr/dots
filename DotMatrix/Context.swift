//
//  Context.swift
//  TempleAttendance
//
//  Created by Mark Vader on 11/15/15.
//  Copyright © 2015 VaderApps. All rights reserved.
//

import Foundation
import CoreData
import UIKit

protocol UIApplicationDelegateWithPSC {
    
    func providePersistentStoreCoordinator() -> NSPersistentStoreCoordinator
    
}

class ContextManager {
    
  //  static let sharedInstance = ContextManager(concurrencyType: .MainQueueConcurrencyType)
    
    lazy var context: NSManagedObjectContext = {
        return {
            let modelURL = NSBundle.mainBundle().URLForResource("DotMatrix", withExtension: "momd")
            let mom = NSManagedObjectModel(contentsOfURL: modelURL!)
            let appDelegateWithPSC = UIApplication.sharedApplication().delegate as! UIApplicationDelegateWithPSC
            let psc = appDelegateWithPSC.providePersistentStoreCoordinator()
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let storeURL = (urls[urls.endIndex-1]).URLByAppendingPathComponent("TempleAttendance")
            var error: NSError? = nil
            var store: NSPersistentStore?
            do {
                store = try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch let error1 as NSError {
                error = error1
                store = nil
            } catch {
                fatalError()
            }
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = psc
            
            return managedObjectContext
        }()
    }()
    
    private init(concurrencyType: NSManagedObjectContextConcurrencyType ) {
        
    }
    
}
