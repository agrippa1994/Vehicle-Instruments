//
//  Label+CoreDataProperties.swift
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

extension Label {

    @NSManaged var name: String?
    @NSManaged var width: Double
    @NSManaged var height: Double
    @NSManaged var x: Double
    @NSManaged var y: Double
    @NSManaged var script: String?
    @NSManaged var configuration: Configuration?

}
