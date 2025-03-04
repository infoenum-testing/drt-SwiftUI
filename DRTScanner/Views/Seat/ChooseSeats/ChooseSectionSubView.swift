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
    
    var body: some View {
        VStack {
            List(seatLabels, id: \.self) { seat in
                ChooseSectionCell(seatLabel: seat)
                    .frame(height: 80)
                
                    .onTapGesture {
                        selectedSeat = seat
                        isPresent = false
                        selectedSection = seat
                       // fetchRows(for: selecteds) 
                    }
                Divider()
            }
            .listStyle(.plain)
            .background(Color.customWhite)
        }
        .background(Color.customWhite)
        .onAppear {
            fetchSections()
        }
    }
    
    private func fetchSections() {
        IQAPIClient.getSection(code: "289-6385") { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let section):
                    print(section)
                    seatLabels = section
                case .failure(let error):
                    print("Failed to fetch sections: \(error.localizedDescription)")
                    fetchSectionsFromCoreData()
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

struct ChooseSectionCell: View {
    var seatLabel: String
    
    var body: some View {
        HStack {
            Spacer()
            Text(seatLabel)
                .font(.custom("Verlag-Bold", size: 32))
                .foregroundColor(Color.showCodeButton)
            Spacer()
        }.listRowSeparator(.hidden)
            .background(Color.customWhite)
    }
}

struct ChooseSectionCellView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSectionSubView(selectedSeat: .constant(""), isPresent: .constant(false))
    }
}
