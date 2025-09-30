//
//  ChooseSectionSubView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//


import SwiftUI
import IQAPIClient
import CoreData
import Shimmer

// This view displays a list of seat sections for the user to choose from.
struct ChooseSectionSubView: View {
    @State private var seatLabels: [String] = []
    @Binding var selectedSeat: String
    @Binding var isPresent: Bool
    @State private var selectedSection: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    @State private var shouldShowLoading: Bool = false
    @State private var shouldShowView: Bool = false
    var body: some View {
        VStack {
            // List of seat sections
            if seatLabels.isEmpty && shouldShowLoading {
                List(1...8, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.neutralText.opacity(0.2))
                        .frame(height: 80)
                        .listRowBackground(Color.primaryText)
                        .shimmering(
                            active: true,
                            gradient: Gradient(colors: [
                                Color.primaryText.opacity(0.5),
                                Color.primaryText,
                                Color.primaryText.opacity(0.5)
                            ])
                        )
                }
                .listStyle(.plain)
                .background(Color.primaryText)
            } else if seatLabels.isEmpty {
                Spacer()
                CustomsText(title: "No seat found", textFont: .verlagBookAdaptive(size: 20), foregroundColour: Color.neutralText)
                Spacer()
            } else {
                List(seatLabels, id: \.self) { seat in
                    ChooseSectionCell(seatLabel: seat)
                        .frame(height: 80)
                        .listRowBackground(Color.primaryText)
                        .onTapGesture {
                            // When a seat is tapped, update selection and dismiss view
                            withAnimation {
                                selectedSeat = seat
                                isPresent = false
                                selectedSection = seat
                            }
                        }
                    
                    Divider()
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .background(Color.primaryText)
            }
        }
        .background(Color.primaryText)
        .opacity(shouldShowView ? 1 : 0)
        .onAppear {
            shouldShowView = false
            // Fetch sections from Core Data if offline, otherwise from API
            if isOfflineMode {
                shouldShowView = true
                fetchSectionsFromCoreData()
                return
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    shouldShowView = true
                }
                fetchSections()
            }
        }
    }
    
    // Fetches seat sections from the API
    private func fetchSections() {
        shouldShowLoading = true
        IQAPIClient.getSection(code: savedShowCode ?? "") { result in
            DispatchQueue.main.async {
                shouldShowLoading = false
            }
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

/*
 List(seatLabels, id: \.self) { seat in
     ChooseSectionCell(seatLabel: seat)
         .frame(height: 80)
         .listRowBackground(Color.primaryText)
         .onTapGesture {
             // When a seat is tapped, update selection and dismiss view
             withAnimation {
                 selectedSeat = seat
                 isPresent = false
                 selectedSection = seat
             }
         }
         .listRowBackground(Color.primaryText)
     
     Divider()
         .listRowSeparator(.hidden)
 }
 .listStyle(.plain)
 .background(Color.primaryText)
 */
