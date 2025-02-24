//
//  ChooseRowSubView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI
import IQAPIClient

struct ChooseRowSubView: View {
    @State private var rowSelect: [String] = []
    @Binding var selectedSeat: String
    @Binding var isPresent: Bool
    @Binding var selectedSection: String
    @Binding var selectedRow: String
    
    var body: some View {
        VStack {
            List(rowSelect, id: \.self) { seat in
                ChooseRowCell(row: seat)
                    .frame(height: 80)
                    .onTapGesture {
                        selectedSeat = seat
                        selectedRow = seat
                        isPresent = false
                    }
            }
            .listStyle(PlainListStyle())
            .background(Color.customWhite)
        }
        .background(Color.customWhite)
        .onAppear {
            fetchRows(for: selectedSection)
        }
    }
    
    private func fetchRows(for section: String) {
           IQAPIClient.getRow(code: "289-6385", section: section) { result in
               DispatchQueue.main.async {
                   switch result {
                   case .success(let row):
                       rowSelect = row
                   case .failure(let error):
                       print("Failed to fetch rows: \(error.localizedDescription)")
                   }
               }
           }
       }
   }

struct ChooseRowCell: View {
    var row: String
    
    var body: some View {
        HStack {
            Text(row)
                .font(.custom("Verlag-Bold", size: 32))
                .foregroundColor(Color.showCodeButton)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.customWhite)
    }
}

struct ChooseRowCellView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseRowSubView(selectedSeat: .constant(""), isPresent: .constant(false), selectedSection: .constant(""), selectedRow: .constant(""))
    }
}
