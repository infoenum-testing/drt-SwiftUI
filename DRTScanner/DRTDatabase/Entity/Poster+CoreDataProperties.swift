//
//  Poster+CoreDataProperties.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 15/02/25.
//
//

import Foundation
import CoreData


extension Poster {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Poster> {
        return NSFetchRequest<Poster>(entityName: "Poster")
    }

    @NSManaged public var height: NSNumber?
    @NSManaged public var href: String?
    @NSManaged public var width: NSNumber?

}

extension Poster : Identifiable {

}
