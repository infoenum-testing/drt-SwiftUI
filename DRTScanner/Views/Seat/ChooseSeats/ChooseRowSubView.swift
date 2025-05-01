//
//  ChooseRowSubView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI
import IQAPIClient
import CoreData

struct ChooseRowSubView: View {
    @State private var rowSelect: [String] = []
    @Binding var selectedSeat: String
    @Binding var isPresent: Bool
    @Binding var selectedSection: String
    @Binding var selectedRow: String
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    
    var body: some View {
        // Main view body: displays a list of rows for seat selection
        VStack {
            List(rowSelect, id: \.self) { seat in
                ChooseRowCell(row: seat)
                    .frame(height: 80)
                    .listRowBackground(Color.white)
                    .onTapGesture {
                        // When a seat is tapped, update selectedSeat and selectedRow, and dismiss the view
                        selectedSeat = seat
                        selectedRow = seat
                        isPresent = false
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
            // On appear, fetch rows either from Core Data (offline) or API (online)
            if isOfflineMode {
                fetchRowsCoreData(for: selectedSection)
                return
            }
            else {
                fetchRows(for: selectedSection)
            }
        }
    }
    
    // Fetch rows from API for the given section
    private func fetchRows(for section: String) {
        IQAPIClient.getRow(code: savedShowCode ?? "", section: section) { result in
               DispatchQueue.main.async {
                   switch result {
                   case .success(let row):
                       rowSelect = row.compactMap { $0["row"] as? String }
                   case .failure(let error):
                       print("Failed to fetch rows: \(error.localizedDescription)")
                   }
               }
           }
       }
    
    // Fetch rows from Core Data for the given section (offline mode)
    private func fetchRowsCoreData(for section: String) {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "section == %@", section)
            do {
                let rows = try viewContext.fetch(fetchRequest)
                if !rows.isEmpty {
                    rowSelect = Array(Set(rows.map { $0.row ?? "" })).sorted()
                } else {
                }
            } catch {
                print("Failed to fetch rows from Core Data: \(error.localizedDescription)")
            }
        }
   }
