//
//  Stats+CoreDataProperties.swift
//  
//
//  Created by IE Mac 05 on 19/06/25.
//
//

import Foundation
import CoreData


extension Stats {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stats> {
        return NSFetchRequest<Stats>(entityName: "Stats")
    }

    @NSManaged public var seatsScannable: NSNumber?
    @NSManaged public var seatsScannedByDevice: NSNumber?
    @NSManaged public var seatsScannedTotal: NSNumber?
    @NSManaged public var totalSeats: NSNumber?

}
