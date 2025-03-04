//
//  SeatLookupView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI
import IQAPIClient
import CoreData

struct SeatLookupView: View {
    @State private var seatText: String = ""
    @Binding var isPresented: Bool
    @State private var isSeatLookupPresented = false
    @State private var isSectionLookupPresented = false
    @State private var isRowLookupPresented = false
    @State private var selectedSection: String = ""
    @State private var selectedRow: String = ""
    @State private var selectedSeat: String = ""
    @State private var isLoading = false
    @State private var orderDetails: OrderDetailModel = OrderDetailModel()
    @State private var ordersDetailCoreData: Order?
    @State private var order: Orders?
    @StateObject private var lookupByOrderViewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @State private var showResultView = false

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

                TextField("Select Seat", text: $seatText)
                    .font(.custom("Verlag-Bold", size: 42))
                    .foregroundColor(.customWhite)
                    .padding(.leading, 10)
                    .frame(width: 350, height: 85)
                    .background(Color.clear)
                    .multilineTextAlignment(.leading)
                    .onChange(of: selectedSection) { _ in seatText = seatDisplayText }
                    .onChange(of: selectedRow) { _ in seatText = seatDisplayText }
                    .onChange(of: selectedSeat) { _ in seatText = seatDisplayText }
            }
            .frame(width: 400, height: 85)
            .background(Color.showCodeButton)

            TableView(
                isSeatLookupPresented: $isSeatLookupPresented,
                isSectionLookupPresented: $isSectionLookupPresented,
                isRowLookupPresented: $isRowLookupPresented,
                selectedSection: $selectedSection,
                selectedRow: $selectedRow,
                selectedSeat: $selectedSeat
            )
            .frame(width: 400, height: 580)
            .background(Color.clear)

            HStack {
                Spacer()
                Button(action: {
                    continueButtonTapped()
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(width: 36, height: 36)
                    } else {
                        Text(StringConstants.Common.continueText)
                            .font(.custom("Verlag-Bold", size: 36))
                            .foregroundColor(.customWhite)
                            .frame(width: 400, height: 60)
                            .background(Color.showCodeButton)
                    }
                }
                .disabled(isLoading)
                Spacer()
            }
            .frame(width: 400, height: 60)
        }
        .customSheetView(isPresented: $showResultView) {
            LookupOrderResultView(
                inputText: String(orderDetails.oid ?? 24241),
                dismissAction: { showResultView = false },
                errorMessage: nil,
                order: order
            )
        }.padding([.leading, .trailing], 20)
        
        .customSheetView(isPresented: $isSeatLookupPresented) {
            withAnimation(.easeInOut(duration: 0.3)) {
                ChooseSeatView(
                    isPresented: $isSeatLookupPresented,
                    selectedSeat: $selectedSeat,
                    selectedSection: $selectedSection,
                    selectedRow: $selectedRow
                )
            }
        }
        .customSheetView(isPresented: $isSectionLookupPresented) {
            withAnimation(.easeInOut(duration: 0.3)) {
                ChooseSectionView(isPresented: $isSectionLookupPresented, selectedSeat: $selectedSection)
            }
        }
        .customSheetView(isPresented: $isRowLookupPresented) {
            withAnimation(.easeInOut(duration: 0.3)) {
                ChooseRowView(
                    isPresented: $isRowLookupPresented,
                    selectedSeat: $selectedRow,
                    selectedSection: $selectedSection,
                    selectedRow: $selectedRow
                )
            }
        }
    }

    private func continueButtonTapped() {
        guard !selectedSection.isEmpty, !selectedRow.isEmpty, !selectedSeat.isEmpty else {
            print("Please select a section, row, and seat before continuing.")
            return
        }
        
        isLoading = true

        IQAPIClient.getSeatsResults(code: "289-6385", section: selectedSection, row: selectedRow, seat: selectedSeat) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let orderDetail):
                    print("Order Details: \(orderDetail)")
                    self.orderDetails = orderDetail
                    self.order = Orders(
                        buyerName: orderDetail.buyerName,
                        cc: orderDetail.cc,
                        phone: nil,
                        orderId: orderDetail.oid,
                        studioId: nil,
                        success: true,
                        message: ""
                    )

                    Task {
                        await lookupByOrderViewModel.fetchSeats(c: "289-6385", q: String(orderDetails.oid ?? 24241))
                    }
                    self.showResultView = true

                case .failure(let error):
                    print("Failed to fetch seat details: \(error.localizedDescription)")

                    if let cachedOrder = fetchOrderDetailFromCoreData(section: selectedSection, row: selectedRow, seat: selectedSeat) {
                        self.order = Orders(
                            buyerName: cachedOrder.buyer_name,
                            cc: cachedOrder.cc,
                            phone: cachedOrder.phone,
                            orderId: cachedOrder.oid?.intValue,
                            studioId: nil,
                            success: true,
                            message: ""
                        )
                        self.showResultView = true
                    }
                }
            }
        }
    }

    
    private func fetchOrderDetailFromCoreData(section: String, row: String, seat: String) -> Order? {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "section == %@ AND row == %@ AND seat == %@", section, row, seat)
        
        do {
            let results = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
            if let seat = results.first {
                orderDetails.oid = seat.oid?.intValue
                return seat.order
            }
        } catch {
            print("Failed to fetch order detail from Core Data: \(error.localizedDescription)")
        }
        
        return nil
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
            
            SeatLookupCell(action: {
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
