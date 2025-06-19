//
//  Product+CoreDataProperties.swift
//  
//
//  Created by IE Mac 05 on 19/06/25.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var orderId: Int64
    @NSManaged public var name: String?
    @NSManaged public var variantName: String?
    @NSManaged public var qrCode: String?
    @NSManaged public var qty: Int64
    @NSManaged public var qtyScanned: Int64
    @NSManaged public var locally_scanned: Int64
    @NSManaged public var date_scanned: Date?
    @NSManaged public var iconSrc: String?
    @NSManaged public var order: Order?
    @NSManaged public var show: Show?

}
