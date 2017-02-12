//
//  Thing+CoreDataProperties.swift
//  FRCDelegateTester
//
//  Created by Tim Ekl on 2017.02.11.
//  Copyright © 2017 Tim Ekl. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Thing {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Thing> {
        return NSFetchRequest<Thing>(entityName: "Thing");
    }

    @NSManaged public var dateAdded: NSDate?
    @NSManaged public var identifier: String?

}
