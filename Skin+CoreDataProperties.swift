//
//  Skin+CoreDataProperties.swift
//  
//
//  Created by IE Mac 05 on 15/02/25.
//
//

import Foundation
import CoreData


extension Skin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Skin> {
        return NSFetchRequest<Skin>(entityName: "Skin")
    }

    @NSManaged public var background_href: String?
    @NSManaged public var color_1_bg: String?
    @NSManaged public var color_1_text: String?
    @NSManaged public var color_2_bg: String?
    @NSManaged public var color_2_text: String?
    @NSManaged public var logo_href: String?

}
