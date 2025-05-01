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
    // Tracks if stats have been saved to Core Data
    private var isStatsSaved = false
    private let viewContext: NSManagedObjectContext
    
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    // Fetches stats from API or Core Data depending on offline mode
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
    
    // Loads stats from Core Data and saves them if not already saved
    private func loadStatsFromCoreData() {
        let totalSeats = fetchTotalSeats()
        let scannableSeats = fetchScannableSeats()
        let scannedSeats = fetchScannedSeats()
        
        if !isStatsSaved {
            Task {
                await deleteOldStats()
                await saveStatsToCoreData(totalSeats: totalSeats, scannableSeats: scannableSeats, scannedSeats: scannedSeats)
                isStatsSaved = true
            }
        }
        
        Task { @MainActor in
            stats = StatsModel(totalSeats: totalSeats, seatsScannable: scannableSeats, seatsScannedTotal: scannedSeats)
            objectWillChange.send()
            isLoading = false
        }
    }
    
    // Deletes old stats from Core Data
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
    
    // Saves new stats to Core Data
    private func saveStatsToCoreData(totalSeats: Int, scannableSeats: Int, scannedSeats: Int) async {
        let statsEntity = Stats(context: viewContext)
        statsEntity.total_seats = NSNumber(value: totalSeats)
        statsEntity.seats_scannable = NSNumber(value: scannableSeats)
        statsEntity.seats_scanned_total = NSNumber(value: scannedSeats)
        statsEntity.seats_scanned_by_device = 0
        
        do {
            try viewContext.save()
            print("New stats saved successfully!")
        } catch {
            print("Error saving stats to Core Data: \(error)")
        }
    }
    
    // Fetches scanning stats from the API
    private func getScanningStats() async throws -> StatsModel {
        return try await withCheckedThrowingContinuation { continuation in
            IQAPIClient.getShowCodeData(code: savedShowCode ?? "") { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response.stats ?? StatsModel())
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // Fetches the total number of seats from Core Data
    private func fetchTotalSeats() -> Int {
        fetchSeatCount(predicate: nil)
    }
    
    // Fetches the number of scannable seats (total minus non-scannable)
    private func fetchScannableSeats() -> Int {
        let totalSeats = fetchTotalSeats()
        let nonScannableSeats = fetchSeatCount(predicate: NSPredicate(format: "oid == ''"))
        
        let scannableSeats = totalSeats - nonScannableSeats
        print("Scannable Seats Count:", scannableSeats)
        return scannableSeats
    }
    
    // Fetches the number of scanned seats
    private func fetchScannedSeats() -> Int {
        fetchSeatCount(predicate: NSPredicate(format: "date_scanned != nil"))
    }
    
    // Helper to fetch seat count with an optional predicate
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
}
