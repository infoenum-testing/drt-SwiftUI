//
//  SeatLookupView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//


import SwiftUI

struct SeatLookupView: View {
    @State private var seatText: String = ""
    @Binding var isPresented: Bool
    @State private var isSeatLookupPresented = false
    @State private var isSectionLookupPresented = false
    @State private var isRowLookupPresented = false
    @State private var selectedSection: String = ""
    @State private var selectedRow: String = ""
    @State private var selectedSeat: String = ""
    
    private var seatDisplayText: String {
         [selectedSection, selectedRow, selectedSeat]
             .filter { !$0.isEmpty }
             .joined(separator: " - ")
     }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                }) {
                    Image("left_side_arrow")
                }
                
                TextField("Seat", text: .constant(seatDisplayText))
                    .font(.custom("Verlag-Bold", size: 42))
                    .foregroundColor(.customWhite)
                    .padding(.leading, 10)
                    .frame(width: 350, height: 85)
                    .background(Color.clear)
                    .multilineTextAlignment(.leading)
                
            }
            .frame(width: 400, height: 85)
            .background(Color.showCodeButton)

            TableView(isSeatLookupPresented: $isSeatLookupPresented, isSectionLookupPresented: $isSectionLookupPresented, isRowLookupPresented: $isRowLookupPresented, selectedSection: $selectedSection, selectedRow: $selectedRow, selectedSeat: $selectedSeat)
                .frame(width: 400, height: 580)
                .background(Color.clear)
            
            HStack {
                Spacer()
                Button(action: {
                    print("Continue button tapped")
                }) {
                    Text("CONTINUE")
                        .font(.custom("Verlag-Bold", size: 36))
                        .foregroundColor(.customWhite)
                        .frame(width: 400, height: 60)
                        .background(Color.showCodeButton)
                }
                Spacer()
            }
            .frame(width: 400, height: 60)
        }.customSheetView(isPresented: $isSeatLookupPresented) {
            withAnimation(.easeInOut(duration: 0.3)) {
                ChooseSeatView(isPresented: $isSeatLookupPresented, selectedSeat: $selectedSeat)
            }
        }
        .customSheetView(isPresented: $isSectionLookupPresented) {
            withAnimation(.easeInOut(duration: 0.3)) {
                ChooseSectionView(isPresented: $isSectionLookupPresented, selectedSeat: $selectedSection)
            }
        }
        .customSheetView(isPresented: $isRowLookupPresented) {
            withAnimation(.easeInOut(duration: 0.3)) {
                ChooseRowView(isPresented: $isRowLookupPresented, selectedSeat: $selectedRow)
            }
        }
    }
}

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
            .frame(height: 100)
            
            SeatRowLookupCell(action: {
                isRowLookupPresented = true
            }, selectedSeat: selectedRow)
            .frame(height: 100)
            
            SeatLookupCell (action: {
                isSeatLookupPresented = true
            }, selectedSeat: selectedSeat)
            .frame(height: 100)
        }
    }
}

struct SeatLookupView_Previews: PreviewProvider {
    static var previews: some View {
        SeatLookupView(isPresented: .constant(false))
    }
}
