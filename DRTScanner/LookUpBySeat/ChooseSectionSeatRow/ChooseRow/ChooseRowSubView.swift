//
//  ChooseRowSubView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI
import IQAPIClient
import CoreData
import Shimmer

struct ChooseRowSubView: View {
    @State private var rowSelect: [String] = []
    @Binding var selectedSeat: String
    @Binding var isPresent: Bool
    @Binding var selectedSection: String
    @Binding var selectedRow: String
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    @State private var shouldShowLoading: Bool = false
    @State private var shouldShowView: Bool = false
    var body: some View {
        // Main view body: displays a list of rows for seat selection
        VStack {
            if rowSelect.isEmpty && shouldShowLoading {
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
            } else if rowSelect.isEmpty {
                Spacer()
                CustomsText(title: "No seat found", textFont: .verlagBookAdaptive(size: 20), foregroundColour: Color.neutralText)
                Spacer()
            }  else {
                List(rowSelect, id: \.self) { seat in
                    ChooseRowCell(row: seat)
                        .frame(height: 80)
                        .listRowBackground(Color.primaryText)
                        .onTapGesture {
                            // When a seat is tapped, update selectedSeat and selectedRow, and dismiss the view
                            withAnimation {
                                selectedSeat = seat
                                selectedRow = seat
                                isPresent = false
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
            // On appear, fetch rows either from Core Data (offline) or API (online)
            if isOfflineMode {
                shouldShowView = true
                fetchRowsCoreData(for: selectedSection)
                return
            }
            else {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    shouldShowView = true
                }
                fetchRows(for: selectedSection)
            }
        }
    }
    
    // Fetch rows from API for the given section
    private func fetchRows(for section: String) {
        shouldShowLoading = true
        IQAPIClient.getRow(code: savedShowCode ?? "", section: section) { result in
               DispatchQueue.main.async {
                   shouldShowLoading = false
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
