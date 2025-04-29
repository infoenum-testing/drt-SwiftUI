//
//  ChooseSectionSubView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//


import SwiftUI
import IQAPIClient
import CoreData

struct ChooseSectionSubView: View {
    @State private var seatLabels: [String] = []
    @Binding var selectedSeat: String
    @Binding var isPresent: Bool
    @State private var selectedSection: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    
    var body: some View {
        VStack {
            List(seatLabels, id: \.self) { seat in
                ChooseSectionCell(seatLabel: seat)
                    .frame(height: 80)
                    .listRowBackground(Color.white)
                    .onTapGesture {
                        selectedSeat = seat
                        isPresent = false
                        selectedSection = seat
                    }
                    .listRowBackground(Color.white)
                    
                Divider()
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .background(Color.customWhite)
        }
        .background(Color.customWhite)
        .onAppear {
            if isOfflineMode {
                fetchSectionsFromCoreData()
                return
            }
            else {
                fetchSections()
            }
        }
    }
    
    private func fetchSections() {
        IQAPIClient.getSection(code: savedShowCode ?? "") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let sectionData):
                    print("Raw API response: \(sectionData)")
                    
                    seatLabels = sectionData.compactMap { $0["section"] as? String }
                    
                case .failure(let error):
                    print("Failed to fetch sections: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchSectionsFromCoreData() {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        
        do {
            let sections = try viewContext.fetch(fetchRequest)
            seatLabels = Array(Set(sections.map { $0.section ?? "" })).sorted()
        } catch {
            print("Failed to fetch sections from Core Data: \(error.localizedDescription)")
        }
    }
}
