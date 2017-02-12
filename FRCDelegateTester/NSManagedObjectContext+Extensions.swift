//
//  NSManagedObjectContext+Extensions.swift
//  FRCDelegateTester
//
//  Created by Tim Ekl on 2017.02.11.
//  Copyright © 2017 Tim Ekl. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    
    convenience init(storeURL: URL?, concurrencyType: NSManagedObjectContextConcurrencyType) {
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let type = (storeURL == nil) ? NSInMemoryStoreType : NSSQLiteStoreType
        try! coordinator.addPersistentStore(ofType: type, configurationName: nil, at: storeURL, options: nil)
        
        self.init(concurrencyType: concurrencyType)
        self.persistentStoreCoordinator = coordinator
    }
    
    func insertThing() -> Thing {
        let thing = NSEntityDescription.insertNewObject(forEntityName: "Thing", into: self) as! Thing
        thing.dateAdded = NSDate()
        thing.identifier = UUID().uuidString
        return thing
    }
    
}
