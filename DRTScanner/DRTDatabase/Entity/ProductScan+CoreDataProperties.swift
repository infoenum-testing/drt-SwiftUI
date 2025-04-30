//
//  ProductScan+CoreDataProperties.swift
//  
//
//  Created by IE Mac 05 on 30/04/25.
//
//

import Foundation
import CoreData


extension ProductScan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProductScan> {
        return NSFetchRequest<ProductScan>(entityName: "ProductScan")
    }

    @NSManaged public var scanDate: Date?
    @NSManaged public var qrCode: String?
    @NSManaged public var product: Product?

}
