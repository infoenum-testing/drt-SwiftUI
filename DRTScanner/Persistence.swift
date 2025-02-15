//
//  Persistence.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 05/02/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "DRT_Scanner")  // Make sure this matches your .xcdatamodeld name
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }
}
