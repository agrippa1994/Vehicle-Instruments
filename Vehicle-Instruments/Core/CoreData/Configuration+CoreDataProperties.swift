//
//  Configuration+CoreDataProperties.swift
//  Vehicle-Instruments
//
//  Created by Manuel Leitold on 18.02.16.
//  Copyright © 2016 mani1337. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Configuration {

    @NSManaged var name: String?
    @NSManaged var index: Int16
    @NSManaged var labels: NSSet?

}
