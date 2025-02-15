//
//  Stats+CoreDataProperties.swift
//  
//
//  Created by IE Mac 05 on 15/02/25.
//
//

import Foundation
import CoreData


extension Stats {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stats> {
        return NSFetchRequest<Stats>(entityName: "Stats")
    }

    @NSManaged public var seats_scannable: NSNumber?
    @NSManaged public var seats_scanned_by_device: NSNumber?
    @NSManaged public var seats_scanned_total: NSNumber?
    @NSManaged public var total_seats: NSNumber?

}
