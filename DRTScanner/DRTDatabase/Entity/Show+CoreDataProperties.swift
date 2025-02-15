//
//  Show+CoreDataProperties.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 15/02/25.
//
//

import Foundation
import CoreData

extension Show {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Show> {
        return NSFetchRequest<Show>(entityName: "Show")
    }

    @NSManaged public var message: String?
    @NSManaged public var show_dt: String?
    @NSManaged public var show_id: String?
    @NSManaged public var studio_id: String?
    @NSManaged public var valid: NSNumber?
    @NSManaged public var orders: NSSet?
    @NSManaged public var seats: NSSet?

}

// MARK: Generated accessors for orders
extension Show {

    @objc(addOrdersObject:)
    @NSManaged public func addToOrders(_ value: Order)

    @objc(removeOrdersObject:)
    @NSManaged public func removeFromOrders(_ value: Order)

    @objc(addOrders:)
    @NSManaged public func addToOrders(_ values: NSSet)

    @objc(removeOrders:)
    @NSManaged public func removeFromOrders(_ values: NSSet)

}

// MARK: Generated accessors for seats
extension Show {

    @objc(addSeatsObject:)
    @NSManaged public func addToSeats(_ value: Seat)

    @objc(removeSeatsObject:)
    @NSManaged public func removeFromSeats(_ value: Seat)

    @objc(addSeats:)
    @NSManaged public func addToSeats(_ values: NSSet)

    @objc(removeSeats:)
    @NSManaged public func removeFromSeats(_ values: NSSet)

}

extension Show : Identifiable {

}
