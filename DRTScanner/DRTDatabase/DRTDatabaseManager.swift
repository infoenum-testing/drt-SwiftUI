//
//  DRTDatabaseManager.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/02/25.
//


import CoreData

class DRTDatabaseManager {
    
    var managedObjectContext: NSManagedObjectContext?
    
    static let shared: DRTDatabaseManager = {
        let context = PersistenceController.shared.container.viewContext
        return DRTDatabaseManager(context: context)
    }()
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    static func modelURL() -> URL? {
        if let modelURL = Bundle.main.url(forResource: "DRT_Scanner", withExtension: IQModelExtension.momd) {
            return modelURL
        }
        return Bundle.main.url(forResource: "DRT_Scanner", withExtension: IQModelExtension.mom)
    }
    
    func saveOrders(from orderDetails: [Orders], context: NSManagedObjectContext) {
        context.perform {
            for detail in orderDetails {
                let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "oid == %d", detail.orderId ?? 0)

                do {
                    let existingOrders = try context.fetch(fetchRequest)
                    
                    if !existingOrders.isEmpty {
                        print("Order already exists: \(detail.orderId ?? 0)")
                        continue
                    }
                    
                    let order = Order(context: context)
                    
                    order.buyer_name = detail.buyerName
                    order.cc = detail.cc
                    order.oid = (Int64(detail.orderId ?? 0)) as NSNumber
                    order.phone = detail.phone

                    try context.save()
                    print("Order saved: \(detail.orderId ?? 0)")
                } catch {
                    print("Failed to save order: \(error.localizedDescription)")
                }
            }
        }
    }

    func allRecordsSortByAttribute(_ attribute: String?, fromTable table: String) -> [Any] {
        var sortDescriptor: NSSortDescriptor?
        
        if let attribute = attribute, !attribute.isEmpty {
            sortDescriptor = NSSortDescriptor(key: attribute, ascending: true)
        }
        
        return allObjectsFromTable(table, sortDescriptor: sortDescriptor)
        
    }
    
    func allObjectsFromTable(_ tableName: String, sortDescriptor: NSSortDescriptor?) -> [Any] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: tableName)
        
        if let sortDescriptor = sortDescriptor {
            fetchRequest.sortDescriptors = [sortDescriptor]
        }
        
        do {
            let results = try managedObjectContext?.fetch(fetchRequest)
            return results ?? []
        } catch {
            print("Error fetching records: \(error)")
            return []
        }
    }
    
    
    func deleteAllTableRecord(_ table: String) {
    }
    
    func insertStatsRecordInStatsTable(_ stats: [String: Any]) {
    }
    
    func createOrder(orderAttributes: [String: Any], context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            let order = Order(context: context)
            
            order.oid = orderAttributes[StringConstants.Attributes.oid] as? NSNumber
            order.buyer_name = orderAttributes[StringConstants.Attributes.buyerName] as? String
            order.cc = orderAttributes[StringConstants.Attributes.cc] as? String
            order.phone = orderAttributes[StringConstants.Attributes.phone] as? String
            
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
            fetchRequest.predicate = NSPredicate(format: StringConstants.Formate.oid, orderAttributes[StringConstants.Attributes.oid] as? NSNumber ?? 0)
            
            do {
                if let order = try context.fetch(fetchRequest).first {
                    order.buyer_name = orderAttributes[StringConstants.Attributes.buyerName] as? String
                    order.cc = orderAttributes[StringConstants.Attributes.cc] as? String
                    order.phone = orderAttributes[StringConstants.Attributes.phone] as? String
                    
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
    
    func deleteAllOrders(context: NSManagedObjectContext, completion: @escaping (Bool) -> Void) {
        context.perform {
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Order.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

            do {
                try context.execute(deleteRequest)
                try context.save()
                print("All orders deleted successfully!")
                completion(true)
            } catch {
                print("Failed to delete all orders: \(error.localizedDescription)")
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
        
        if let barcode = seatAttributes[StringConstants.Attributes.barcode] as? String {
            let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: StringConstants.Formate.barcode, barcode)
            
            do {
                let existingSeats = try context.fetch(fetchRequest)
                
                if let existingSeat = existingSeats.first {
                    existingSeat.row = seatAttributes[StringConstants.Attributes.row] as? String
                    existingSeat.seat = seatAttributes[StringConstants.Attributes.seat] as? String
                    existingSeat.section = seatAttributes[StringConstants.Attributes.section] as? String
                    existingSeat.qrCode = seatAttributes[StringConstants.Attributes.qrCode] as? String
                    existingSeat.handicapped = seatAttributes[StringConstants.Attributes.handicapped] as? NSNumber
                    existingSeat.date_scanned = seatAttributes[StringConstants.Attributes.datesScanned] as? Date
                    
                    return existingSeat
                } else {
                    let newSeat = Seat(context: context)
                    newSeat.barcode = seatAttributes[StringConstants.Formate.barcode] as? String
                    newSeat.row = seatAttributes[StringConstants.Attributes.row] as? String
                    newSeat.seat = seatAttributes[StringConstants.Attributes.seat] as? String
                    newSeat.section = seatAttributes[StringConstants.Attributes.section] as? String
                    newSeat.qrCode = seatAttributes[StringConstants.Attributes.qrCode] as? String
                    newSeat.handicapped = seatAttributes[StringConstants.Attributes.handicapped] as? NSNumber
                    newSeat.date_scanned = seatAttributes[StringConstants.Attributes.datesScanned] as? Date
                    
                    return newSeat
                }
            } catch let error {
                print("Error fetching seat: \(error.localizedDescription)")
                return nil
            }
        }
        
        return nil
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
        
        show.show_id = showAttributes[StringConstants.Attributes.showId] as? String
        show.message = showAttributes[StringConstants.Attributes.message] as? String
        show.show_dt = showAttributes[StringConstants.Attributes.showDt] as? String
        show.studio_id = showAttributes[StringConstants.Attributes.studioId] as? String
        show.valid = showAttributes[StringConstants.Attributes.valid] as? NSNumber
        
        do {
            try context.save()
            print("Show record inserted successfully!")
            return show
        } catch {
            print("Failed to insert Show record: \(error.localizedDescription)")
            return nil
        }
    }

    func insertOrUpdateShowRecord(in context: NSManagedObjectContext, showAttributes: [String: Any]) -> Show? {
        let showID = showAttributes[StringConstants.Attributes.showId] as? String ?? ""
        
        let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: StringConstants.Formate.showId, showID)
        
        do {
            let results = try context.fetch(fetchRequest)
            let show = results.first ?? Show(context: context) // Use existing or create new
            
            show.show_id = showID
            show.message = showAttributes[StringConstants.Attributes.message] as? String
            show.show_dt = showAttributes[StringConstants.Attributes.showDt] as? String
            show.studio_id = showAttributes[StringConstants.Attributes.studioId] as? String
            show.valid = showAttributes[StringConstants.Attributes.valid] as? NSNumber
            
            try context.save()
            print("Show record inserted/updated successfully!")
            return show
        } catch {
            print("Failed to insert/update Show record: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateShowRecord(_ show: Show, in context: NSManagedObjectContext, showAttributes: [String: Any]) -> Show? {
        show.message = showAttributes[StringConstants.Attributes.message] as? String
        show.show_dt = showAttributes[StringConstants.Attributes.showDt] as? String
        show.studio_id = showAttributes[StringConstants.Attributes.studioId] as? String
        show.valid = showAttributes[StringConstants.Attributes.valid] as? NSNumber
        
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
        guard let seatsKey = statsAttributes[StringConstants.Attributes.seats] as? NSNumber else {
            print("Missing seats key")
            return nil
        }
        
        let fetchRequest: NSFetchRequest<Stats> = Stats.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: StringConstants.Formate.totalSeats, seatsKey)
        
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
        guard let logoHref = skinAttributes[StringConstants.Attributes.logoHref] as? String else {
            print("Missing logo_href key")
            return nil
        }
        
        let fetchRequest: NSFetchRequest<Skin> = Skin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: StringConstants.Formate.logoHref, logoHref)
        
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
        if let backgroundHref = attributes[StringConstants.Attributes.backgroundHref] as? String {
            skin.background_href = backgroundHref
        }
        if let color1Bg = attributes[StringConstants.Attributes.color_1_bg] as? String {
            skin.color_1_bg = color1Bg
        }
        if let color1Text = attributes[StringConstants.Attributes.color_1_text] as? String {
            skin.color_1_text = color1Text
        }
        if let color2Bg = attributes[StringConstants.Attributes.color_2_bg] as? String {
            skin.color_2_bg = color2Bg
        }
        if let color2Text = attributes[StringConstants.Attributes.color_2_text] as? String {
            skin.color_2_text = color2Text
        }
        if let logoHref = attributes[StringConstants.Attributes.logoHref] as? String {
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
        guard let posterHref = posterAttributes[StringConstants.Attributes.href] as? String else {
            print("Missing href key")
            return nil
        }
        
        let fetchRequest: NSFetchRequest<Poster> = Poster.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: StringConstants.Formate.href, posterHref)
        
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
        if let height = attributes[StringConstants.Attributes.height] as? NSNumber {
            poster.height = height
        }
        if let href = attributes[StringConstants.Attributes.href] as? String {
            poster.href = href
        }
        if let width = attributes[StringConstants.Attributes.width] as? NSNumber {
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
        guard let barcode = scanAttributes[StringConstants.Attributes.barcode] as? String else {
            print("Missing barcode key")
            return nil
        }
        
        let fetchRequest: NSFetchRequest<Scan> = Scan.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: StringConstants.Formate.barcode, barcode)
        
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
        if let barcode = attributes[StringConstants.Attributes.barcode] as? String {
            scan.barcode = barcode
        }
        if let isScannedOut = attributes[StringConstants.Attributes.isScannedOut] as? NSNumber {
            scan.is_scanned_out = isScannedOut
        }
        if let qrCode = attributes[StringConstants.Attributes.qrCode] as? String {
            scan.qrCode = qrCode
        }
        if let timeStamp = attributes[StringConstants.Attributes.timeStamp] as? NSNumber {
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
  
    func syncServerData(serverDict: [String: Any], progressBlock: ((Float) -> Void)?, completionBlock: ((Bool, Error?) -> Void)?) {
        DispatchQueue.global(qos: .default).async {
            
            let deletionResults = self.deleteAllRecords()
            if !deletionResults {
                print("Failed to delete some records.")
            }
            
            let showDict = self.prepareShowData(from: serverDict)
            
            DispatchQueue.main.async {
                if let show = self.insertUpdateShowRecordInShowTable(showAttributes: showDict) {
                    let orders = serverDict[StringConstants.Attributes.orders] as? [[Any]] ?? []
                    let soldSeats = serverDict[StringConstants.Attributes.sold] as? [[Any]] ?? []
                    let unSoldSeats = serverDict[StringConstants.Attributes.unsold] as? [[Any]] ?? []
                    
                    let totalRecords = CGFloat(orders.count + soldSeats.count + unSoldSeats.count)
                    var currentlyProcessingRecord: CGFloat = 0
                    
                    self.handleOrders(orders, show: show, totalRecords: totalRecords, progressBlock: progressBlock, currentlyProcessingRecord: &currentlyProcessingRecord)
                    
                    self.handleSoldSeats(soldSeats, show: show, totalRecords: totalRecords, progressBlock: progressBlock, currentlyProcessingRecord: &currentlyProcessingRecord, isSold: true)

                    self.handleSoldSeats(unSoldSeats, show: show, totalRecords: totalRecords, progressBlock: progressBlock, currentlyProcessingRecord: &currentlyProcessingRecord, isSold: false)
                }
                DispatchQueue.main.async {
                    completionBlock?(true, nil)
                }
            }
        }
    }

    private func deleteAllRecords() -> (Bool) {
        let seatDeletionSuccess = self.deleteAllTableRecord(forEntity: Seat.self)
        let orderDeletionSuccess = self.deleteAllTableRecord(forEntity: Order.self)
        let showDeletionSuccess = self.deleteAllTableRecord(forEntity: Show.self)
        let scanDeletionSuccess = self.deleteAllTableRecord(forEntity: Scan.self)
        
        return (seatDeletionSuccess && orderDeletionSuccess && showDeletionSuccess && scanDeletionSuccess)
    }

    private func prepareShowData(from serverDict: [String: Any]) -> [String: Any] {
        var showDict = serverDict
        showDict.removeValue(forKey: StringConstants.Attributes.orders)
        showDict.removeValue(forKey: StringConstants.Attributes.seats)
        
        if let showId = showDict[StringConstants.Attributes.showId] as? NSNumber {
            showDict[StringConstants.Attributes.showId] = "\(showId)"
        }
        if let studioId = showDict[StringConstants.Attributes.studioId] as? NSNumber {
            showDict[StringConstants.Attributes.studioId] = "\(studioId)"
        }
        
        return showDict
    }

    private func handleOrders(_ orders: [[Any]], show: Show, totalRecords: CGFloat, progressBlock: ((Float) -> Void)?, currentlyProcessingRecord: inout CGFloat) {
        for serverOrder in orders {
            currentlyProcessingRecord += 1
            progressBlock?(Float(currentlyProcessingRecord / totalRecords))
            
            let orderAttributes: [String: Any] = [
                StringConstants.Attributes.oid: serverOrder[0],
                StringConstants.Attributes.buyerName: serverOrder[1],
                StringConstants.Attributes.cc: serverOrder[2],
                StringConstants.Attributes.phone: serverOrder[3]
            ]
            DispatchQueue.main.async {
                if let order = self.insertUpdateOrderRecord(orderAttributes: orderAttributes) {
                    order.show = show
                
                    if let oid = serverOrder[0] as? Int {
                      
                        let predicate = NSPredicate(format: StringConstants.NSPredicate.oid, "\(oid)")
                        if let seats = self.fetchObjects(forEntity: Seat.self, withPredicate: predicate), !seats.isEmpty {
                            let seatSet = NSSet(array: seats)
                            order.addToSeats(seatSet)
                        } else {
                            print("No seats found for order \(order)")
                        }
                    }
                }
            }
        }
    }

    private func handleSoldSeats(_ soldSeats: [[Any]], show: Show, totalRecords: CGFloat, progressBlock: ((Float) -> Void)?, currentlyProcessingRecord: inout CGFloat, isSold: Bool) {
        for serverSeat in soldSeats {
            currentlyProcessingRecord += 1

                progressBlock?(Float(currentlyProcessingRecord / totalRecords))
            
            var qrCode: String? = nil
            if let qrCodeArray = serverSeat[5] as? [String], qrCodeArray.count >= 4 {
                qrCode = qrCodeArray.joined(separator: "-")
            }
            
            let seatAttributes: [String: Any] = [
                StringConstants.Attributes.oid: serverSeat[0],
                StringConstants.Attributes.section: serverSeat[1],
                StringConstants.Attributes.row: serverSeat[2],
                StringConstants.Attributes.seat: serverSeat[3],
                StringConstants.Attributes.barcode: serverSeat[4],
                StringConstants.Attributes.qrCode: qrCode ?? "",
                StringConstants.Attributes.handicapped: serverSeat[7],
                StringConstants.Attributes.isSold: isSold
            ]
            DispatchQueue.main.async {
                if let seat = self.insertSeatRecord(seatAttributes: seatAttributes) {
                    seat.show = show
                    
                    if seat.order == nil, let oid = serverSeat[0] as? Int {
                        let predicate = NSPredicate(format: StringConstants.NSPredicate.oid, "\(oid)")
                        if let order = self.fetchFirstObject(fromTable: Order.self, predicate: predicate) {
                            seat.order = order
                        }
                    }
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
        
        let predicate = NSPredicate(format: StringConstants.NSPredicate.showidBarcodeQrCode, showID, barcode ?? "", qrCode ?? "")
        
        return fetchFirstObject(fromTable: Seat.self, predicate: predicate)
    }
    
    func sectionsWithShowID(showID: String) -> [String] {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return []
        }
        
        let predicate = NSPredicate(format: StringConstants.NSPredicate.showShowId, showID)
        
        let seats: [Seat] = fetchObjects(forEntity: Seat.self, withPredicate: predicate) ?? []
        
        let sections = Set(seats.compactMap { $0.section }).sorted()
        
        return Array(sections)
    }
    
    func rowsWithShowID(showID: String, section: String) -> [String] {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return []
        }
        
        let predicate = NSPredicate(format: StringConstants.NSPredicate.showIdSection, showID, section)
        
        let seats: [Seat] = fetchObjects(forEntity: Seat.self, withPredicate: predicate) ?? []
        
        let rows = Set(seats.compactMap { $0.row }).sorted()
        
        return Array(rows)
    }
    
    func seatsWithShowID(showID: String, section: String, row: String) -> [String] {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return []
        }
        
        let predicate = NSPredicate(format: StringConstants.NSPredicate.showIdSectionRow, showID, section, row)
        
        let seats: [Seat] = fetchObjects(forEntity: Seat.self, withPredicate: predicate) ?? []
        
        let seatIdentifiers = Set(seats.compactMap { $0.seat }).sorted()
        
        return Array(seatIdentifiers)
    }
    
    func resultsForSeatLookup(showID: String, section: String, row: String, seat: String) -> Seat? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        let predicate = NSPredicate(format: StringConstants.NSPredicate.sectionRowSeatShowId, section, row, seat, showID)
        
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
        
        let predicate = NSPredicate(format: StringConstants.NSPredicate.oidShowId, orderID, showID)
        
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
        
        let predicate = NSPredicate(format: StringConstants.NSPredicate.cc, creditCard)
        
        let orders = fetchObjects(forEntity: Order.self, withPredicate: predicate)
        return orders
    }
    
    func ordersWithPhoneNumber(phoneNumber: String) -> [Order]? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        let predicate = NSPredicate(format: StringConstants.Formate.phoneContains, phoneNumber)
        
        let orders = fetchObjects(forEntity: Order.self, withPredicate: predicate)
        return orders
    }
    
    func ordersWithLastName(lastName: String) -> [Order]? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        let predicate = NSPredicate(format: StringConstants.Formate.buyerName, lastName)
        
        let orders = fetchObjects(forEntity: Order.self, withPredicate: predicate)
        return orders
    }
    
    func insertSeatRecord(seatAttributes: [String: Any]) -> Seat? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        let newSeat = Seat(context: context)
        if let barcodeValue = seatAttributes[StringConstants.Attributes.barcode] as? NSString {
            newSeat.barcode = barcodeValue as String
        } else {
            print("Error: Barcode is nil or not a valid string")
        }

        newSeat.oid = seatAttributes[StringConstants.Attributes.oid] as? NSNumber
        newSeat.row = seatAttributes[StringConstants.Attributes.row] as? String
        newSeat.seat = seatAttributes[StringConstants.Attributes.seat] as? String
        newSeat.section = seatAttributes[StringConstants.Attributes.section] as? String
        newSeat.qrCode = seatAttributes[StringConstants.Attributes.qrCode] as? String
        if let handicappedValue = seatAttributes[StringConstants.Attributes.handicapped] as? Bool {
            newSeat.handicapped = NSNumber(value: handicappedValue)
        } else {
            print("Error: Handicapped attribute is not a valid Boolean")
        }
        newSeat.date_scanned = seatAttributes[StringConstants.Attributes.datesScanned] as? Date
        
        if newSeat.row == nil || newSeat.seat == nil {
            print("Error: Missing required attributes for seat")
            return nil
        }
        
        do {
            try context.save()
            return newSeat
        } catch let error {
            print("Error saving seat: \(error.localizedDescription)")
            return nil
        }
    }

    func insertUpdateOrderRecord(orderAttributes: [String: Any]) -> Order? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        if let orderId = orderAttributes[StringConstants.Attributes.oid] as? Int {
            let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: StringConstants.Formate.oid, "\(orderId)")
            
            do {
                let newOrder = Order(context: context)
                newOrder.oid = orderAttributes[StringConstants.Attributes.oid] as? NSNumber
                newOrder.buyer_name = orderAttributes[StringConstants.Attributes.buyerName] as? String
                newOrder.cc = orderAttributes[StringConstants.Attributes.cc] as? String
                newOrder.phone = orderAttributes[StringConstants.Attributes.phone] as? String
                try context.save()
                return newOrder
            } catch let error {
                print("Error fetching order: \(error.localizedDescription)")
                return nil
            }
        }
        
        return nil
    }

    func insertUpdateShowRecordInShowTable(showAttributes: [String: Any]) -> Show? {
        guard let context = managedObjectContext else {
            print("Managed Object Context is not available")
            return nil
        }
        
        if let showId = showAttributes[StringConstants.Attributes.showId] as? String {
            let fetchRequest: NSFetchRequest<Show> = Show.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: StringConstants.Formate.showId, showId)
            
            do {
                let newShow = Show(context: context)
                newShow.show_id = showId
                newShow.message = showAttributes[StringConstants.Attributes.message] as? String
                newShow.show_dt = showAttributes[StringConstants.Attributes.showDt] as? String
                newShow.studio_id = showAttributes[StringConstants.Attributes.studioId] as? String
                if let valid = showAttributes[StringConstants.Attributes.valid] as? Bool {
                    newShow.valid = NSNumber(value: valid)
                }
                try context.save()
                return newShow
            } catch let error {
                print("Error fetching show: \(error.localizedDescription)")
                return nil
            }
        }
        
        return nil
    }
    
}
