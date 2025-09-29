//
//  Skin+CoreDataProperties.swift
//  
//
//  Created by IE Mac 05 on 19/06/25.
//
//

import Foundation
import CoreData


extension Skin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Skin> {
        return NSFetchRequest<Skin>(entityName: "Skin")
    }
    @NSManaged public var color_Invalid: String?
    @NSManaged public var color_Previous: String?
    @NSManaged public var color_Valid: String?
    
    @NSManaged public var background_href: String?
    @NSManaged public var color_1_bg: String?
    @NSManaged public var color_1_text: String?
    @NSManaged public var color_2_bg: String?
    @NSManaged public var color_2_text: String?
    @NSManaged public var color_neutral_bg: String?
    @NSManaged public var color_neutral_text: String?
    @NSManaged public var logo_href: String?
    @NSManaged public var colorButtonBg: String?
    @NSManaged public var colorButtonText: String?
    @NSManaged public var colorGoldenTicket: String?
    @NSManaged public var colorGrayText: String?
    @NSManaged public var color1Shade: String?

}
