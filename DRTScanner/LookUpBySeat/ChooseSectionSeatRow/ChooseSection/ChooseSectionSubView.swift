//
//  ChooseSectionSubView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//


import SwiftUI
import IQAPIClient
import CoreData

// This view displays a list of seat sections for the user to choose from.
struct ChooseSectionSubView: View {
    @State private var seatLabels: [String] = [] // Holds the list of seat section labels
    @Binding var selectedSeat: String // The currently selected seat (bound to parent)
    @Binding var isPresent: Bool // Controls the presentation state (bound to parent)
    @State private var selectedSection: String = "" // Stores the selected section locally
    @Environment(\.managedObjectContext) private var viewContext // Core Data context
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false // Offline mode flag
    @AppStorage("showCode") private var savedShowCode: String? // Saved show code for API
    
    var body: some View {
        VStack {
            // List of seat sections
            List(seatLabels, id: \.self) { seat in
                ChooseSectionCell(seatLabel: seat)
                    .frame(height: 80)
                    .listRowBackground(Color.primaryText)
                    .onTapGesture {
                        // When a seat is tapped, update selection and dismiss view
                        selectedSeat = seat
                        isPresent = false
                        selectedSection = seat
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
            // Fetch sections from Core Data if offline, otherwise from API
            if isOfflineMode {
                fetchSectionsFromCoreData()
                return
            }
            else {
                fetchSections()
            }
        }
    }
    
    // Fetches seat sections from the API
    private func fetchSections() {
        IQAPIClient.getSection(code: savedShowCode ?? "") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let sectionData):
                    print("Raw API response: \(sectionData)")
                    // Extract section names from API response
                    seatLabels = sectionData.compactMap { $0["section"] as? String }
                case .failure(let error):
                    print("Failed to fetch sections: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Fetches seat sections from Core Data (offline mode)
    private func fetchSectionsFromCoreData() {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        
        do {
            let sections = try viewContext.fetch(fetchRequest)
            // Extract unique section names and sort them
            seatLabels = Array(Set(sections.map { $0.section ?? "" })).sorted()
        } catch {
            print("Failed to fetch sections from Core Data: \(error.localizedDescription)")
        }
    }
}
