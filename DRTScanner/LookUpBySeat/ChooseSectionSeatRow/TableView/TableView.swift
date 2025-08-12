//
//  TableView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/04/25.
//

import SwiftUI

// This struct defines a table view for selecting seat section, row, and seat with lookup dialogs.
struct TableView: View {
    // Bindings to control the presentation of lookup dialogs
    @Binding var isSeatLookupPresented: Bool
    @Binding var isSectionLookupPresented: Bool
    @Binding var isRowLookupPresented: Bool
    // Bindings for the currently selected section, row, and seat
    @Binding var selectedSection: String
    @Binding var selectedRow: String
    @Binding var selectedSeat: String
    
    var body: some View {
        List {
            // Section selection cell
            SeatSectionLookupCell(action: {
                withAnimation {
                    isSectionLookupPresented = true
                }
            }, selectedSeat: selectedSection)
            .listRowBackground(Color.primaryText)
            .frame(height: 100.adaptiveForIpad)
            .onChange(of: selectedSection) { _ in
                if !selectedSection.isEmpty {
                    selectedRow = ""
                    selectedSeat = ""
                }
            }
            
            // Row selection cell
            SeatRowLookupCell(action: {
                withAnimation {
                    isRowLookupPresented = true
                }
            }, selectedSeat: selectedRow)
            .listRowBackground(Color.primaryText)
            .frame(height: 100.adaptiveForIpad)
            // Disable if no section is selected
            .disabled(selectedSection.isEmpty)
            .opacity(selectedSection.isEmpty ? 0.5 : 1.0)
            .onChange(of: selectedRow) { _ in
                if !selectedRow.isEmpty {
                    selectedSeat = ""
                }
            }
            
            SeatLookupCell(action: {
                withAnimation {
                    isSeatLookupPresented = true
                }
            }, selectedSeat: selectedSeat)
            .listRowBackground(Color.primaryText)
            .frame(height: 100.adaptiveForIpad)
            .disabled(selectedRow.isEmpty)
            .opacity(selectedRow.isEmpty ? 0.5 : 1.0)
        }
        .listStyle(.plain)
        .padding(0)
        .background(Color.primaryText)
    }
}
