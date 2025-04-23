//
//  TableView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 14/04/25.
//

import SwiftUI

struct TableView: View {
    @Binding var isSeatLookupPresented: Bool
    @Binding var isSectionLookupPresented: Bool
    @Binding var isRowLookupPresented: Bool
    @Binding var selectedSection: String
    @Binding var selectedRow: String
    @Binding var selectedSeat: String
    
    var body: some View {
        List {
            SeatSectionLookupCell(action: {
                isSectionLookupPresented = true
            }, selectedSeat: selectedSection)
            .listRowBackground(Color.white)
            .frame(height: 100.adaptiveForIpad)
            .onChange(of: selectedSection) { _ in
                if !selectedSection.isEmpty {
                    selectedRow = ""
                    selectedSeat = ""
                }
            }
            
            SeatRowLookupCell(action: {
                isRowLookupPresented = true
            }, selectedSeat: selectedRow)
            .listRowBackground(Color.white)
            .frame(height: 100.adaptiveForIpad)
            .disabled(selectedSection.isEmpty)
            .opacity(selectedSection.isEmpty ? 0.5 : 1.0)
            .onChange(of: selectedRow) { _ in
                if !selectedRow.isEmpty {
                    selectedSeat = ""
                }
            }
            
            SeatLookupCell(action: {
                isSeatLookupPresented = true
            }, selectedSeat: selectedSeat)
            .listRowBackground(Color.white)
            .frame(height: 100.adaptiveForIpad)
            .disabled(selectedRow.isEmpty)
            .opacity(selectedRow.isEmpty ? 0.5 : 1.0)
        }.listStyle(.plain)
        
            .padding(0)
            .background(Color.customWhite)
    }
}
