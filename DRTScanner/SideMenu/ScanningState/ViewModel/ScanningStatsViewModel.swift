//
//  ScanningStatsViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 28/02/25.
//


import SwiftUI
import IQAPIClient
import CoreData

@MainActor
class ScanningStatsViewModel: ObservableObject {
    @Published var stats: StatsModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var isStatsSaved = false
    private let viewContext: NSManagedObjectContext
    
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    @AppStorage("deviceScanCount") private var deviceScanCount: Int = 0
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func fetchStats() async {
        isLoading = true
        errorMessage = nil
        
        if !isOfflineMode {
            do {
                let fetchedStats = try await getScanningStats()
                
                await MainActor.run {
                    self.stats = fetchedStats
                }
                
                if let totalSeats = fetchedStats.totalSeats, totalSeats > 0 {
                    print("Valid data received from API, skipping Core Data update.")
                    isLoading = false
                    return
                }
            } catch {
                print("API failed: \(error.localizedDescription)")
                errorMessage = "Failed to fetch data from API. Loading from local storage..."
            }
        }
        
        loadStatsFromCoreData()
    }
    
    private func loadStatsFromCoreData() {
        let totalSeats = fetchTotalSeats()
        let scannableSeats = fetchScannableSeats()
        let scannedSeats = fetchScannedSeats()
        let scannedByDevice = fetchDeviceScannedCount() // ✅ New
        
        if !isStatsSaved {
            Task {
                await deleteOldStats()
                await saveStatsToCoreData(totalSeats: totalSeats, scannableSeats: scannableSeats, scannedSeats: scannedSeats)
                isStatsSaved = true
            }
        }
        
        Task { @MainActor in
            stats = StatsModel(
                totalSeats: totalSeats,
                seatsScannable: scannableSeats,
                seatsScannedTotal: scannedSeats,
                seatsScannedByDevice: scannedByDevice // ✅ Fix for offline mode
            )
            objectWillChange.send()
            isLoading = false
        }
    }
    
    private func deleteOldStats() async {
        let fetchRequest: NSFetchRequest<Stats> = Stats.fetchRequest()
        
        do {
            let statsEntities = try viewContext.fetch(fetchRequest)
            statsEntities.forEach { viewContext.delete($0) }
            try viewContext.save()
            print("Old stats deleted successfully!")
        } catch {
            print("Error deleting old stats from Core Data: \(error)")
        }
    }
    
    private func saveStatsToCoreData(totalSeats: Int, scannableSeats: Int, scannedSeats: Int) async {
        let statsEntity = Stats(context: viewContext)
        statsEntity.totalSeats = NSNumber(value: totalSeats)
        statsEntity.seatsScannable = NSNumber(value: scannableSeats)
        statsEntity.seatsScannedTotal = NSNumber(value: scannedSeats)
        statsEntity.seatsScannedByDevice = NSNumber(value: deviceScanCount)
        
        do {
            try viewContext.save()
            print("New stats saved successfully!")
        } catch {
            print("Error saving stats to Core Data: \(error)")
        }
    }
    
    func getScanningStats() async throws -> StatsModel {
        return try await withCheckedThrowingContinuation { continuation in
            IQAPIClient.getShowCodeData(code: savedShowCode ?? "") { result in
                switch result {
                case .success(let response):
                    if let skin = response.skin {
                        ColorManager.shared.updateSkin(to: skin)
                    }
                    continuation.resume(returning: response.stats ?? StatsModel())
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func fetchTotalSeats() -> Int {
        fetchSeatCount(predicate: nil)
    }
    
    private func fetchScannableSeats() -> Int {
        let totalSeats = fetchTotalSeats()
        let nonScannableSeats = fetchSeatCount(predicate: NSPredicate(format: "orderId == ''"))
        
        let scannableSeats = totalSeats - nonScannableSeats
        print("Scannable Seats Count:", scannableSeats)
        return scannableSeats
    }
    
    private func fetchScannedSeats() -> Int {
        fetchSeatCount(predicate: NSPredicate(format: "date_scanned != nil"))
    }
    
    private func fetchSeatCount(predicate: NSPredicate?) -> Int {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            return try viewContext.count(for: fetchRequest)
        } catch {
            print("Error fetching seat count: \(error)")
            return 0
        }
    }
    
    // ✅ New method to fetch scanned by device count from Core Data
    private func fetchDeviceScannedCount() -> Int {
        let fetchRequest: NSFetchRequest<Stats> = Stats.fetchRequest()
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            return results.first?.seatsScannedByDevice?.intValue ?? 0
        } catch {
            print("Failed to fetch device scanned count: \(error)")
            return 0
        }
    }
    
    // ✅ Call this after each successful scan in offline mode
    func incrementDeviceScannedCount() {
        let fetchRequest: NSFetchRequest<Stats> = Stats.fetchRequest()
        do {
            let results = try viewContext.fetch(fetchRequest)
            let statsEntity: Stats
            if let existingStats = results.first {
                statsEntity = existingStats
            } else {
                // If no Stats entity exists, create one
                statsEntity = Stats(context: viewContext)
                statsEntity.totalSeats = 0
                statsEntity.seatsScannable = 0
                statsEntity.seatsScannedTotal = 0
                statsEntity.seatsScannedByDevice = 0
            }
            let currentCount = statsEntity.seatsScannedByDevice?.intValue ?? 0
            statsEntity.seatsScannedByDevice = NSNumber(value: currentCount + 1)
            try viewContext.save()
            print("Device scanned count incremented to \(currentCount + 1)")
            // Update the published stats property as well
            if stats == nil {
                stats = StatsModel()
            }
            stats?.seatsScannedByDevice = currentCount + 1
            objectWillChange.send()
        } catch {
            print("Failed to increment scanned count: \(error)")
        }
    }
}
