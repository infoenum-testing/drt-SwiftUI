//
//  Order+CoreDataProperties.swift
//  
//
//  Created by IE Mac 05 on 15/02/25.
//
//

import Foundation
import CoreData


extension Order {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Order> {
        return NSFetchRequest<Order>(entityName: "Order")
    }

    @NSManaged public var buyer_name: String?
    @NSManaged public var cc: String?
    @NSManaged public var oid: NSNumber?
    @NSManaged public var phone: String?
    @NSManaged public var seats: NSSet?
    @NSManaged public var show: Show?

}

// MARK: Generated accessors for seats
extension Order {

    @objc(addSeatsObject:)
    @NSManaged public func addToSeats(_ value: Seat)

    @objc(removeSeatsObject:)
    @NSManaged public func removeFromSeats(_ value: Seat)

    @objc(addSeats:)
    @NSManaged public func addToSeats(_ values: NSSet)

    @objc(removeSeats:)
    @NSManaged public func removeFromSeats(_ values: NSSet)

}
