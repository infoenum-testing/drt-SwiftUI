//
//  Seat+CoreDataProperties.swift
//  
//
//  Created by IE Mac 05 on 19/06/25.
//
//

import Foundation
import CoreData


extension Seat {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Seat> {
        return NSFetchRequest<Seat>(entityName: "Seat")
    }

    @NSManaged public var barcode: String?
    @NSManaged public var date_scanned: Date?
    @NSManaged public var handicapped: NSNumber?
    @NSManaged public var id: NSNumber?
    @NSManaged public var orderId: NSNumber?
    @NSManaged public var locally_scanned: Int64
    @NSManaged public var qrCode: String?
    @NSManaged public var row: String?
    @NSManaged public var seat: String?
    @NSManaged public var section: String?
    @NSManaged public var order: Order?
    @NSManaged public var show: Show?

}

extension Seat : Identifiable {

}
