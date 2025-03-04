//
//  ScanningStatsViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 28/02/25.
//


import SwiftUI
import IQAPIClient

//@MainActor
//class ScanningStatsViewModel: ObservableObject {
//    @Published var stats: StatsModel?
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//
//    func fetchStats() async {
//        isLoading = true
//        errorMessage = nil
//        do {
//            let fetchedStats = try await getScanningStats()
//            stats = fetchedStats
//        } catch {
//            errorMessage = error.localizedDescription
//        }
//        isLoading = false
//    }
//
//    private func getScanningStats() async throws -> StatsModel {
//        return try await withCheckedThrowingContinuation { continuation in
//            IQAPIClient.getShowCodeData(code: "289-6385") { result in
//                switch result {
//                case .success(let response):
//                    continuation.resume(returning: response.stats!)
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//            }
//        }
//    }
//}

import CoreData
import SwiftUI

@MainActor
class ScanningStatsViewModel: ObservableObject {
    @Published var stats: StatsModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    private var isStatsSaved = false
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func fetchStats() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedStats = try await getScanningStats()
            
            await MainActor.run {
                self.stats = fetchedStats
            }
            
            if fetchedStats.totalSeats ?? -1 > 0 {
                print("Valid data received from API, skipping Core Data update.")
                isLoading = false
                return
            }
        } catch {
            print("API failed: \(error.localizedDescription)")
            errorMessage = "Failed to fetch data from API. Loading from local storage..."
        }
        
        let totalSeats = fetchTotalSeats()
        let scannableSeats = fetchScannableSeats()
        let scannedSeats = fetchScannedSeats()
        
        if !isStatsSaved {
            await deleteOldStats()
            await saveStatsToCoreData(totalSeats: totalSeats, scannableSeats: scannableSeats, scannedSeats: scannedSeats)
            isStatsSaved = true
        }
        
        await MainActor.run {
            stats = StatsModel(totalSeats: totalSeats, seatsScannable: scannableSeats, seatsScannedTotal: scannedSeats)
            objectWillChange.send()
        }
        
        isLoading = false
    }

    
    private func deleteOldStats() async {
        let fetchRequest: NSFetchRequest<Stats> = Stats.fetchRequest()
        
        do {
            let statsEntities = try viewContext.fetch(fetchRequest)
            for statsEntity in statsEntities {
                viewContext.delete(statsEntity)
            }
            
            try viewContext.save()
            print("Old stats deleted successfully!")
        } catch {
            print("Error deleting old stats from Core Data: \(error)")
        }
    }
    
    private func saveStatsToCoreData(totalSeats: Int, scannableSeats: Int, scannedSeats: Int) async {
        let statsEntity = Stats(context: viewContext)
        
        statsEntity.total_seats = (Int32(totalSeats)) as NSNumber
        statsEntity.seats_scannable = (Int32(scannableSeats)) as NSNumber
        statsEntity.seats_scanned_total = (Int32(scannedSeats)) as NSNumber
        statsEntity.seats_scanned_by_device = 0
        
        do {
            try viewContext.save()
            print("New stats saved successfully!")
        } catch {
            print("Error saving stats to Core Data: \(error)")
        }
    }
    
    private func getScanningStats() async throws -> StatsModel {
        return try await withCheckedThrowingContinuation { continuation in
            IQAPIClient.getShowCodeData(code: "289-6385") { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response.stats!)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func fetchTotalSeats() -> Int {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        do {
            let count = try viewContext.count(for: fetchRequest)
            return count
        } catch {
            print("Error fetching total seats: \(error)")
            return 0
        }
    }
    
    private func fetchScannableSeats() -> Int {
        let totalSeats = fetchTotalSeats()
        let nonScannableSeats = fetchNonScannableSeats()
        
        let scannableSeats = totalSeats - nonScannableSeats
        print("Scannable Seats Count:", scannableSeats)
        return scannableSeats
    }
    
    
    private func fetchNonScannableSeats() -> Int {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "oid == ''")
        
        do {
            let count = try viewContext.count(for: fetchRequest)
            print("Non-Scannable Seats Count:", count)
            return count
        } catch {
            print("Error fetching non-scannable seats: \(error)")
            return 0
        }
    }
    
    private func fetchScannedSeats() -> Int {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date_scanned != nil")
        do {
            let count = try viewContext.count(for: fetchRequest)
            return count
        } catch {
            print("Error fetching scanned seats: \(error)")
            return 0
        }
    }
}
