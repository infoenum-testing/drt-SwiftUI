//
//  DRTDatabaseManager.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/02/25.
//


import CoreData

class DRTDatabaseManager {
    
    var managedObjectContext: NSManagedObjectContext?
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    func createOrder(orderAttributes: [String: Any], context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            let order = Order(context: context)
            
            order.oid = orderAttributes["oid"] as? NSNumber
            order.buyer_name = orderAttributes["buyer_name"] as? String
            order.cc = orderAttributes["cc"] as? String
            order.phone = orderAttributes["phone"] as? String
            
            do {
                try context.save()
                print("Order saved successfully!")
                completion(true)
            } catch {
                print("Failed to save order: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    func updateOrder(orderAttributes: [String: Any], context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "oid == %@", orderAttributes["oid"] as? NSNumber ?? 0)
            
            do {
                if let order = try context.fetch(fetchRequest).first {
                    order.buyer_name = orderAttributes["buyer_name"] as? String
                    order.cc = orderAttributes["cc"] as? String
                    order.phone = orderAttributes["phone"] as? String
                    
                    try context.save()
                    print("Order updated successfully!")
                    completion(true)
                } else {
                    print("Order not found.")
                    completion(false)
                }
            } catch {
                print("Failed to update order: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    func fetchOrders(context: NSManagedObjectContext, completion: @escaping ([Order]?) -> Void) {
        context.perform {
            let request: NSFetchRequest<Order> = Order.fetchRequest()
            do {
                let orders = try context.fetch(request)
                completion(orders)
            } catch {
                print("Failed to fetch orders: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    func deleteOrder(order: Order, context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            context.delete(order)
            
            do {
                try context.save()
                print("Order deleted successfully!")
                completion(true)
            } catch {
                print("Failed to delete order: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    func fetchObjects<T: NSManagedObject>(forEntity entity: T.Type, withPredicate predicate: NSPredicate? = nil) -> [T]? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        let entityName = String(describing: entity)
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: entityName)
        fetchRequest.predicate = predicate
        
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            return fetchedObjects
        } catch let error {
            print("Error fetching objects for \(entityName): \(error.localizedDescription)")
            return nil
        }
    }
    
    
    func insertUpdateSeatRecord(seatAttributes: [String: Any]) -> Seat? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        if let barcode = seatAttributes["barcode"] as? String {
            let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "barcode == %@", barcode)
            
            do {
                let existingSeats = try context.fetch(fetchRequest)
                
                if let existingSeat = existingSeats.first {
                    existingSeat.row = seatAttributes["row"] as? String
                    existingSeat.seat = seatAttributes["seat"] as? String
                    existingSeat.section = seatAttributes["section"] as? String
                    existingSeat.qrCode = seatAttributes["qrCode"] as? String
                    existingSeat.handicapped = seatAttributes["handicapped"] as? NSNumber
                    existingSeat.date_scanned = seatAttributes["date_scanned"] as? Date
                    
                    return existingSeat
                } else {
                    let newSeat = Seat(context: context)
                    newSeat.barcode = seatAttributes["barcode"] as? String
                    newSeat.row = seatAttributes["row"] as? String
                    newSeat.seat = seatAttributes["seat"] as? String
                    newSeat.section = seatAttributes["section"] as? String
                    newSeat.qrCode = seatAttributes["qrCode"] as? String
                    newSeat.handicapped = seatAttributes["handicapped"] as? NSNumber
                    newSeat.date_scanned = seatAttributes["date_scanned"] as? Date
                    
                    return newSeat
                }
            } catch let error {
                print("Error fetching seat: \(error.localizedDescription)")
                return nil
            }
        }
        
        return nil
    }
    
    func insertSeatRecord(seatAttributes: [String: Any]) -> Seat? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        let newSeat = Seat(context: context)
        newSeat.barcode = seatAttributes["barcode"] as? String
        newSeat.row = seatAttributes["row"] as? String
        newSeat.seat = seatAttributes["seat"] as? String
        newSeat.section = seatAttributes["section"] as? String
        newSeat.qrCode = seatAttributes["qrCode"] as? String
        newSeat.handicapped = seatAttributes["handicapped"] as? NSNumber
        newSeat.date_scanned = seatAttributes["date_scanned"] as? Date
        
        do {
            try context.save()
            return newSeat
        } catch let error {
            print("Error saving seat: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteSeatRecord(seat: Seat) -> Bool {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return false
        }
        
        context.delete(seat)
        
        do {
            try context.save()
            print("Seat record deleted successfully!")
            return true
        } catch let error {
            print("Failed to delete Seat record: \(error.localizedDescription)")
            return false
        }
    }
    
    
    
    func insertShowRecord(in context: NSManagedObjectContext, showAttributes: [String: Any]) -> Show? {
        let show = Show(context: context)
        
        show.show_id = showAttributes["show_id"] as? String
        show.message = showAttributes["message"] as? String
        show.show_dt = showAttributes["show_dt"] as? String
        show.studio_id = showAttributes["studio_id"] as? String
        show.valid = showAttributes["valid"] as? NSNumber
        
        do {
            try context.save()
            print("Show record inserted successfully!")
            return show
        } catch {
            print("Failed to insert Show record: \(error.localizedDescription)")
            return nil
        }
    }
    
    func insertUpdateShowRecordInShowTable(showAttributes: [String: Any]) -> Show? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        // Check if a Show with the given show_id already exists
        if let showId = showAttributes["show_id"] as? String {
            let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "show_id == %@", showId)
            
            do {
                let existingShows = try context.fetch(fetchRequest)
                
                if let existingShow = existingShows.first {
                    // Update the existing show record
                    existingShow.message = showAttributes["message"] as? String
                    existingShow.show_dt = showAttributes["show_dt"] as? String
                    existingShow.studio_id = showAttributes["studio_id"] as? String
                    existingShow.valid = showAttributes["valid"] as? NSNumber
                    
                    return existingShow
                } else {
                    // Insert new show record if it doesn't exist
                    let newShow = Show(context: context)
                    newShow.show_id = showId
                    newShow.message = showAttributes["message"] as? String
                    newShow.show_dt = showAttributes["show_dt"] as? String
                    newShow.studio_id = showAttributes["studio_id"] as? String
                    newShow.valid = showAttributes["valid"] as? NSNumber
                    
                    return newShow
                }
            } catch let error {
                print("Error fetching show: \(error.localizedDescription)")
                return nil
            }
        }
        
        return nil
    }
    
    func insertUpdateOrderRecord(orderAttributes: [String: Any]) -> Order? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        // Check if an Order with the given oid already exists
        if let orderId = orderAttributes["oid"] as? String {
            let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "oid == %@", orderId)
            
            do {
                let existingOrders = try context.fetch(fetchRequest)
                
                if let existingOrder = existingOrders.first {
                    // Update the existing order record
                    existingOrder.buyer_name = orderAttributes["buyer_name"] as? String
                    existingOrder.cc = orderAttributes["cc"] as? String
                    existingOrder.phone = orderAttributes["phone"] as? String
                    
                    return existingOrder
                } else {
                    // Insert new order record if it doesn't exist
                    let newOrder = Order(context: context)
                    newOrder.oid = orderAttributes["oid"] as? NSNumber
                    newOrder.buyer_name = orderAttributes["buyer_name"] as? String
                    newOrder.cc = orderAttributes["cc"] as? String
                    newOrder.phone = orderAttributes["phone"] as? String
                    
                    return newOrder
                }
            } catch let error {
                print("Error fetching order: \(error.localizedDescription)")
                return nil
            }
        }
        
        return nil
    }
    
    
    func insertOrUpdateShowRecord(in context: NSManagedObjectContext, showAttributes: [String: Any]) -> Show? {
        let showID = showAttributes["show_id"] as? String ?? ""
        
        let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "show_id == %@", showID)
        
        do {
            let results = try context.fetch(fetchRequest)
            let show = results.first ?? Show(context: context) // Use existing or create new
            
            show.show_id = showID
            show.message = showAttributes["message"] as? String
            show.show_dt = showAttributes["show_dt"] as? String
            show.studio_id = showAttributes["studio_id"] as? String
            show.valid = showAttributes["valid"] as? NSNumber
            
            try context.save()
            print("Show record inserted/updated successfully!")
            return show
        } catch {
            print("Failed to insert/update Show record: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateShowRecord(_ show: Show, in context: NSManagedObjectContext, showAttributes: [String: Any]) -> Show? {
        show.message = showAttributes["message"] as? String
        show.show_dt = showAttributes["show_dt"] as? String
        show.studio_id = showAttributes["studio_id"] as? String
        show.valid = showAttributes["valid"] as? NSNumber
        
        do {
            try context.save()
            print("Show record updated successfully!")
            return show
        } catch {
            print("Failed to update Show record: \(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteShowRecord(_ show: Show, in context: NSManagedObjectContext) -> Bool {
        context.delete(show)
        
        do {
            try context.save()
            print("Show record deleted successfully!")
            return true
        } catch {
            print("Failed to delete Show record: \(error.localizedDescription)")
            return false
        }
    }
    
    
    func insertStatsRecord(statsAttributes: [String: Any], context: NSManagedObjectContext) -> Stats? {
        let stats = Stats(context: context)
        updateStatsObject(stats, with: statsAttributes)
        
        do {
            try context.save()
            return stats
        } catch {
            print("Failed to insert Stats record: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Insert or Update Stats Record
    func insertUpdateStatsRecord(statsAttributes: [String: Any], context: NSManagedObjectContext) -> Stats? {
        guard let seatsKey = statsAttributes["seats"] as? NSNumber else {
            print("Missing seats key")
            return nil
        }
        
        let fetchRequest: NSFetchRequest<Stats> = Stats.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "total_seats == %@", seatsKey)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingStats = results.first {
                updateStatsObject(existingStats, with: statsAttributes)
                try context.save()
                return existingStats
            } else {
                return insertStatsRecord(statsAttributes: statsAttributes, context: context)
            }
        } catch {
            print("Failed to fetch Stats for update: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Update an Existing Stats Record
    func updateStatsRecord(stats: Stats, statsAttributes: [String: Any], context: NSManagedObjectContext) -> Stats? {
        updateStatsObject(stats, with: statsAttributes)
        
        do {
            try context.save()
            return stats
        } catch {
            print("Failed to update Stats record: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Delete a Stats Record
    func deleteStatsRecord(stats: Stats, context: NSManagedObjectContext) -> Bool {
        context.delete(stats)
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed to delete Stats record: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Helper Method to Update Stats Object
    private func updateStatsObject(_ stats: Stats, with attributes: [String: Any]) {
        if let seatsScannable = attributes["seats_scannable"] as? NSNumber {
            stats.seats_scannable = seatsScannable
        }
        if let seatsScannedByDevice = attributes["seats_scanned_by_device"] as? NSNumber {
            stats.seats_scanned_by_device = seatsScannedByDevice
        }
        if let seatsScannedTotal = attributes["seats_scanned_total"] as? NSNumber {
            stats.seats_scanned_total = seatsScannedTotal
        }
        if let totalSeats = attributes["total_seats"] as? NSNumber {
            stats.total_seats = totalSeats
        }
    }
    
    func insertSkinRecord(skinAttributes: [String: Any], context: NSManagedObjectContext) -> Skin? {
        let skin = Skin(context: context)
        updateSkinObject(skin, with: skinAttributes)
        
        do {
            try context.save()
            return skin
        } catch {
            print("Failed to insert Skin record: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Insert or Update Skin Record
    func insertUpdateSkinRecord(skinAttributes: [String: Any], context: NSManagedObjectContext) -> Skin? {
        guard let logoHref = skinAttributes["logo_href"] as? String else {
            print("Missing logo_href key")
            return nil
        }
        
        let fetchRequest: NSFetchRequest<Skin> = Skin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "logo_href == %@", logoHref)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingSkin = results.first {
                updateSkinObject(existingSkin, with: skinAttributes)
                try context.save()
                return existingSkin
            } else {
                return insertSkinRecord(skinAttributes: skinAttributes, context: context)
            }
        } catch {
            print("Failed to fetch Skin for update: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Update an Existing Skin Record
    func updateSkinRecord(skin: Skin, skinAttributes: [String: Any], context: NSManagedObjectContext) -> Skin? {
        updateSkinObject(skin, with: skinAttributes)
        
        do {
            try context.save()
            return skin
        } catch {
            print("Failed to update Skin record: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Delete a Skin Record
    func deleteSkinRecord(skin: Skin, context: NSManagedObjectContext) -> Bool {
        context.delete(skin)
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed to delete Skin record: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Helper Method to Update Skin Object
    private func updateSkinObject(_ skin: Skin, with attributes: [String: Any]) {
        if let backgroundHref = attributes["background_href"] as? String {
            skin.background_href = backgroundHref
        }
        if let color1Bg = attributes["color_1_bg"] as? String {
            skin.color_1_bg = color1Bg
        }
        if let color1Text = attributes["color_1_text"] as? String {
            skin.color_1_text = color1Text
        }
        if let color2Bg = attributes["color_2_bg"] as? String {
            skin.color_2_bg = color2Bg
        }
        if let color2Text = attributes["color_2_text"] as? String {
            skin.color_2_text = color2Text
        }
        if let logoHref = attributes["logo_href"] as? String {
            skin.logo_href = logoHref
        }
    }
    
    func insertPosterRecord(posterAttributes: [String: Any], context: NSManagedObjectContext) -> Poster? {
        let poster = Poster(context: context)
        updatePosterObject(poster, with: posterAttributes)
        
        do {
            try context.save()
            return poster
        } catch {
            print("Failed to insert Poster record: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Insert or Update Poster Record
    func insertUpdatePosterRecord(posterAttributes: [String: Any], context: NSManagedObjectContext) -> Poster? {
        guard let posterHref = posterAttributes["href"] as? String else {
            print("Missing href key")
            return nil
        }
        
        let fetchRequest: NSFetchRequest<Poster> = Poster.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "href == %@", posterHref)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingPoster = results.first {
                updatePosterObject(existingPoster, with: posterAttributes)
                try context.save()
                return existingPoster
            } else {
                return insertPosterRecord(posterAttributes: posterAttributes, context: context)
            }
        } catch {
            print("Failed to fetch Poster for update: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Update an Existing Poster Record
    func updatePosterRecord(poster: Poster, posterAttributes: [String: Any], context: NSManagedObjectContext) -> Poster? {
        updatePosterObject(poster, with: posterAttributes)
        
        do {
            try context.save()
            return poster
        } catch {
            print("Failed to update Poster record: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Delete a Poster Record
    func deletePosterRecord(poster: Poster, context: NSManagedObjectContext) -> Bool {
        context.delete(poster)
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed to delete Poster record: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Helper Method to Update Poster Object
    private func updatePosterObject(_ poster: Poster, with attributes: [String: Any]) {
        if let height = attributes["height"] as? NSNumber {
            poster.height = height
        }
        if let href = attributes["href"] as? String {
            poster.href = href
        }
        if let width = attributes["width"] as? NSNumber {
            poster.width = width
        }
    }
    
    func insertScanRecord(scanAttributes: [String: Any], context: NSManagedObjectContext) -> Scan? {
        let scan = Scan(context: context)
        updateScanObject(scan, with: scanAttributes)
        
        do {
            try context.save()
            return scan
        } catch {
            print("Failed to insert Scan record: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Insert or Update Scan Record
    func insertUpdateScanRecord(scanAttributes: [String: Any], context: NSManagedObjectContext) -> Scan? {
        guard let barcode = scanAttributes["barcode"] as? String else {
            print("Missing barcode key")
            return nil
        }
        
        let fetchRequest: NSFetchRequest<Scan> = Scan.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "barcode == %@", barcode)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let existingScan = results.first {
                updateScanObject(existingScan, with: scanAttributes)
                try context.save()
                return existingScan
            } else {
                return insertScanRecord(scanAttributes: scanAttributes, context: context)
            }
        } catch {
            print("Failed to fetch Scan for update: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Delete a Scan Record
    func deleteScanRecord(scan: Scan, context: NSManagedObjectContext) -> Bool {
        context.delete(scan)
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed to delete Scan record: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Helper Method to Update Scan Object
    private func updateScanObject(_ scan: Scan, with attributes: [String: Any]) {
        if let barcode = attributes["barcode"] as? String {
            scan.barcode = barcode
        }
        if let isScannedOut = attributes["is_scanned_out"] as? NSNumber {
            scan.is_scanned_out = isScannedOut
        }
        if let qrCode = attributes["qrCode"] as? String {
            scan.qrCode = qrCode
        }
        if let timeStamp = attributes["timeStamp"] as? NSNumber {
            scan.timeStamp = timeStamp
        }
    }
    
    // MARK: Fetch first object
    func fetchFirstObject<T: NSManagedObject>(fromTable entityType: T.Type, predicate: NSPredicate) -> T? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        let fetchRequest: NSFetchRequest<T> = T.fetchRequest() as! NSFetchRequest<T>
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch let error {
            print("Error fetching object: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    // MARK: Sync server data
    func syncServerData(serverDict: [String: Any], progressBlock: ((Float) -> Void)?, completionBlock: ((Bool, Error?) -> Void)?) {
        DispatchQueue.global(qos: .default).async {
            // Delete all existing records
            self.deleteAllTableRecord(forEntity: Seat.self)
            self.deleteAllTableRecord(forEntity: Order.self)
            self.deleteAllTableRecord(forEntity: Show.self)
            
            var showDict = serverDict
            showDict.removeValue(forKey: "orders")
            showDict.removeValue(forKey: "seats")
            
            // Prepare show data
            if let showId = showDict["show_id"] as? NSNumber {
                showDict["show_id"] = "\(showId)"
            }
            if let studioId = showDict["studio_id"] as? NSNumber {
                showDict["studio_id"] = "\(studioId)"
            }
            
            // Insert or update Show record
            if let show = self.insertUpdateShowRecordInShowTable(showAttributes: showDict) {
                let orders = serverDict["orders"] as? [[Any]] ?? []
                let soldSeats = serverDict["sold"] as? [[Any]] ?? []
                
                let totalRecords = CGFloat(orders.count + soldSeats.count)
                var currentlyProcessingRecord: CGFloat = 0
                
                // Handle orders
                for serverOrder in orders {
                    currentlyProcessingRecord += 1
                    DispatchQueue.main.async {
                        progressBlock?(Float(currentlyProcessingRecord / totalRecords))
                    }
                    
                    let orderAttributes: [String: Any] = [
                        "oid": serverOrder[0],
                        "buyer_name": serverOrder[1],
                        "cc": serverOrder[2],
                        "phone": serverOrder[3]
                    ]
                    if let order = self.insertUpdateOrderRecord(orderAttributes: orderAttributes) {
                        order.show = show
                        
                        if let oid = serverOrder[0] as? String {
                            let predicate = NSPredicate(format: "(oid == %@)", oid)
                            let seats = self.fetchObjects(forEntity: Seat.self, withPredicate: predicate)
                            let seatSet = NSSet(array: seats ?? [])
                            order.addToSeats(seatSet)
                        }
                    }
                }
                
                for serverSeat in soldSeats {
                    currentlyProcessingRecord += 1
                    DispatchQueue.main.async {
                        progressBlock?(Float(currentlyProcessingRecord / totalRecords))
                    }
                    
                    var qrCode: String? = nil
                    if let qrCodeData = serverSeat[5] as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: qrCodeData, options: [])
                            qrCode = String(data: jsonData, encoding: .utf8)
                        } catch {
                            print("Error serializing QR code data: \(error)")
                        }
                    }
                    
                    let seatAttributes: [String: Any] = [
                        "oid": serverSeat[0],
                        "section": serverSeat[1],
                        "row": serverSeat[2],
                        "seat": serverSeat[3],
                        "barcode": serverSeat[4],
                        "qrCode": qrCode ?? "",
                        "handicapped": serverSeat[7]
                    ]
                    if let seat = self.insertSeatRecord(seatAttributes: seatAttributes) {
                        seat.show = show
                        
                        if seat.order == nil, let oid = serverSeat[0] as? String {
                            let predicate = NSPredicate(format: "(oid == %@)", oid)
                            if let order = self.fetchFirstObject(fromTable: Order.self, predicate: predicate) {
                                seat.order = order
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    completionBlock?(true, nil)
                }
            }
        }
    }
    
    func deleteAllTableRecord<T: NSManagedObject>(forEntity entityType: T.Type) -> Bool {
        let context = self.managedObjectContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: String(describing: entityType))
        
        do {
            let objects = try context?.fetch(fetchRequest) as! [NSManagedObject]
            
            for object in objects {
                context?.delete(object)
            }
            
            try context?.save()
            return true
        } catch let error {
            print("Failed to delete records for entity \(entityType): \(error.localizedDescription)")
            return false
        }
    }
    
    func ticketWithShowID(showID: String, barcode: String?, qrCode: String?) -> Seat? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        let predicate = NSPredicate(format: "(show.show_id == %@) AND ((barcode == %@) OR (qrCode == %@))", showID, barcode ?? "", qrCode ?? "")
        
        return fetchFirstObject(fromTable: Seat.self, predicate: predicate)
    }
    
    func sectionsWithShowID(showID: String) -> [String] {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return []
        }
        
        let predicate = NSPredicate(format: "(show.show_id == %@)", showID)
        
        let seats: [Seat] = fetchObjects(forEntity: Seat.self, withPredicate: predicate) ?? []
        
        let sections = Set(seats.compactMap { $0.section }).sorted()
        
        return Array(sections)
    }
    
    func rowsWithShowID(showID: String, section: String) -> [String] {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return []
        }
        
        let predicate = NSPredicate(format: "(show.show_id == %@) AND (section == %@)", showID, section)
        
        let seats: [Seat] = fetchObjects(forEntity: Seat.self, withPredicate: predicate) ?? []
        
        let rows = Set(seats.compactMap { $0.row }).sorted()
        
        return Array(rows)
    }
    
    func seatsWithShowID(showID: String, section: String, row: String) -> [String] {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return []
        }
        
        let predicate = NSPredicate(format: "(show.show_id == %@) AND (section == %@) AND (row == %@)", showID, section, row)
        
        let seats: [Seat] = fetchObjects(forEntity: Seat.self, withPredicate: predicate) ?? []
        
        let seatIdentifiers = Set(seats.compactMap { $0.seat }).sorted()
        
        return Array(seatIdentifiers)
    }
    
    func resultsForSeatLookup(showID: String, section: String, row: String, seat: String) -> Seat? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        let predicate = NSPredicate(format: "(section == %@) AND (row == %@) AND (seat == %@) AND (show.show_id == %@)", section, row, seat, showID)
        
        // Fetch the first seat matching the predicate
        if let seat = fetchFirstObject(fromTable: Seat.self, predicate: predicate) {
            return seat
        }
        
        return nil
    }
    
    func resultsForOrderLookup(showID: String, orderID: String) -> Order? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        let predicate = NSPredicate(format: "(oid == %@) AND (show.show_id == %@)", orderID, showID)
        
        if let order = fetchFirstObject(fromTable: Order.self, predicate: predicate) {
            return order
        }
        return nil
    }
    
    func ordersWithCreditCardNumber(creditCard: String) -> [Order]? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        let predicate = NSPredicate(format: "(cc == %@)", creditCard)
        
        let orders = fetchObjects(forEntity: Order.self, withPredicate: predicate)
        return orders
    }
    
    func ordersWithPhoneNumber(phoneNumber: String) -> [Order]? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        let predicate = NSPredicate(format: "phone CONTAINS [cd] %@", phoneNumber)
        
        let orders = fetchObjects(forEntity: Order.self, withPredicate: predicate)
        return orders
    }
    
    func ordersWithLastName(lastName: String) -> [Order]? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        let predicate = NSPredicate(format: "buyer_name CONTAINS [cd] %@", lastName)
        
        let orders = fetchObjects(forEntity: Order.self, withPredicate: predicate)
        return orders
    }
    
}
