//
//  CoreDataHelper.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/02/25.
//


import CoreData

enum IQModelExtension {
    static let momd = "momd"
    static let mom = "mom"
}

protocol CoreDataHelper {
    
    static func modelURL() -> URL?
    
    func tableNames() -> [String]
    
    // Fetch Records
    func allObjects(from tableName: String) -> [NSManagedObject]
    func allObjects(from tableName: String, where predicate: NSPredicate?) -> [NSManagedObject]
    func allObjects(from tableName: String, sortedBy descriptor: NSSortDescriptor?) -> [NSManagedObject]
    func allObjects(from tableName: String, where predicate: NSPredicate?, sortedBy descriptor: NSSortDescriptor?) -> [NSManagedObject]
    
    func allObjects(from tableName: String, where key: String, equals value: Any) -> [NSManagedObject]
    func allObjects(from tableName: String, where key: String, equals value: Any, sortedBy descriptor: NSSortDescriptor?) -> [NSManagedObject]
    
    func allObjects(from tableName: String, where key: String, contains value: Any) -> [NSManagedObject]
    func allObjects(from tableName: String, where key: String, contains value: Any, sortedBy descriptor: NSSortDescriptor?) -> [NSManagedObject]
    
    func firstObject(from tableName: String) -> NSManagedObject?
    func firstObject(from tableName: String, createIfNotExist: Bool) -> NSManagedObject?
    func firstObject(from tableName: String, where key: String, equals value: Any) -> NSManagedObject?
    func firstObject(from tableName: String, where predicate: NSPredicate) -> NSManagedObject?
    
    func lastObject(from tableName: String) -> NSManagedObject?
    func lastObject(from tableName: String, createIfNotExist: Bool) -> NSManagedObject?
    func lastObject(from tableName: String, where key: String, equals value: Any) -> NSManagedObject?
    func lastObject(from tableName: String, where predicate: NSPredicate) -> NSManagedObject?
    
    func insertRecord(in tableName: String, with attributes: [String: Any]) -> NSManagedObject?
    func updateRecord(_ object: NSManagedObject, with attributes: [String: Any]) -> NSManagedObject?
    func insertOrUpdateRecord(in tableName: String, with attributes: [String: Any], matchingKey key: String, equals value: Any) -> NSManagedObject?
    
    func deleteRecord(_ object: NSManagedObject) -> Bool
    func flushTable(_ tableName: String) -> Bool
}
