//
//  ChooseSeatSubView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI
import IQAPIClient
import CoreData

struct ChooseSeatSubView: View {
    @State private var seatSelect: [String] = []
    @Binding var selectedSeat: String
    @Binding var isPresent: Bool
    @Binding var selectedSection: String
    @Binding var selectedRow: String
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack {
            List(seatSelect, id: \.self) { seat in
                ChooseSeatCell(seatLabel: seat)
                    .frame(height: 80)
                    .onTapGesture {
                        selectedSeat = seat
                        isPresent = false
                    }
            }
            .listStyle(PlainListStyle())
            .background(Color.customWhite)
        }
        .background(Color.customWhite)
        .onAppear {
            fetchSeats(for: selectedSection, row: selectedRow)
        }
    }
    
    private func fetchSeats(for section: String, row: String) {
        IQAPIClient.getSeats(code: "289-6385", section: section, row: row) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let seats):
                    seatSelect = seats
                case .failure(let error):
                    print("Failed to fetch seats: \(error.localizedDescription)")
                    fetchSeatsCoreData(for: section, row: row)
                }
            }
        }
    }
    
    private func fetchSeatsCoreData(for section: String, row: String) {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "section == %@ AND row == %@", section, row)
        
        do {
            let seats = try viewContext.fetch(fetchRequest)
            if !seats.isEmpty {
                seatSelect = seats.map { $0.seat ?? "" }.sorted()
            } else {
                fetchSeats(for: section, row: row)
            }
        } catch {
            print("Failed to fetch seats from Core Data: \(error.localizedDescription)")
            fetchSeats(for: section, row: row)
        }
    }
}


struct ChooseSeatCell: View {
    var seatLabel: String
    
    var body: some View {
        HStack {
            Text(seatLabel)
                .font(.custom("Verlag-Bold", size: 32))
                .foregroundColor(Color.showCodeButton)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .background(Color.customWhite)
    }
}

struct ChooseSeatCellView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSeatSubView(selectedSeat: .constant(""), isPresent: .constant(false), selectedSection: .constant(""), selectedRow: .constant(""))
    }
}
