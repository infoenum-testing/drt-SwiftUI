//
//  Product+CoreDataProperties.swift
//  
//
//  Created by IE Mac 05 on 07/03/25.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var order_id: Int64
    @NSManaged public var name: String?
    @NSManaged public var variantName: String?
    @NSManaged public var qrCode: String?
    @NSManaged public var qty: Int64
    @NSManaged public var qty_scanned: Int64
    @NSManaged public var date_scanned: Date?
    @NSManaged public var icon_src: String?
    @NSManaged public var order: Order?
    @NSManaged public var show: Show?

}
