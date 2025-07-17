//
//  ChooseSeatSubView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI
import IQAPIClient
import CoreData

// This view displays a list of seats for a selected section and row, allowing the user to choose a seat.
struct ChooseSeatSubView: View {
    // Stores the list of seat labels to display
    @State private var seatSelect: [String] = []
    // The currently selected seat (bound to parent view)
    @Binding var selectedSeat: String
    // Controls the presentation state of this view (bound to parent view)
    @Binding var isPresent: Bool
    // The selected section (bound to parent view)
    @Binding var selectedSection: String
    // The selected row (bound to parent view)
    @Binding var selectedRow: String
    // Core Data context for fetching seats in offline mode
    @Environment(\.managedObjectContext) private var viewContext
    // AppStorage for offline mode toggle
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    // AppStorage for the show code
    @AppStorage("showCode") private var savedShowCode: String?
    
    var body: some View {
        VStack {
            // List of available seats
            List(seatSelect, id: \.self) { seat in
                ChooseSeatCell(seatLabel: seat)
                    .frame(height: 80)
                    .listRowBackground(Color.primaryText)
                    .onTapGesture {
                        // When a seat is tapped, update the selected seat and dismiss the view
                        selectedSeat = seat
                        isPresent = false
                    }
                    .listRowBackground(Color.primaryText)
                Divider()
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .background(Color.primaryText)
        }
        .background(Color.primaryText)
        .onAppear {
            // Fetch seats when the view appears, using Core Data if offline mode is enabled
            if isOfflineMode {
                fetchSeatsCoreData(for: selectedSection, row: selectedRow)
            } else {
                fetchSeats(for: selectedSection, row: selectedRow)
            }
        }
    }
    
    // Fetch seats from the API for the given section and row
    private func fetchSeats(for section: String, row: String) {
        IQAPIClient.getSeats(code: savedShowCode ?? "", section: section, row: row) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let seats):
                    // Extract seat numbers from the API response
                    seatSelect = seats.compactMap {
                        if let seatNumber = $0["seat"] as? Int {
                            return "\(seatNumber)"
                        }
                        return nil
                    }
                case .failure(let error):
                    print("Failed to fetch seats: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Fetch seats from Core Data for the given section and row
    private func fetchSeatsCoreData(for section: String, row: String) {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "section == %@ AND row == %@", section, row)
        
        do {
            let seats = try viewContext.fetch(fetchRequest)
            if !seats.isEmpty {
                // If seats are found in Core Data, use them
                seatSelect = seats.map { $0.seat ?? "" }.sorted()
            } else {
                // If not found, fallback to fetching from API
                fetchSeats(for: section, row: row)
            }
        } catch {
            print("Failed to fetch seats from Core Data: \(error.localizedDescription)")
        }
    }
}
