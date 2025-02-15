//
//  Scan+CoreDataProperties.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 15/02/25.
//
//

import Foundation
import CoreData


extension Scan {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Scan> {
        return NSFetchRequest<Scan>(entityName: "Scan")
    }

    @NSManaged public var barcode: String?
    @NSManaged public var is_scanned_out: NSNumber?
    @NSManaged public var qrCode: String?
    @NSManaged public var timeStamp: NSNumber?

}

extension Scan : Identifiable {

}
