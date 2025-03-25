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
    @State private var order: OrdersNewApi?
    @StateObject private var lookupByOrderViewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @State private var showResultView = false
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    
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
            .background(Color.FFCE_62)
            
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
                            .background(Color.FFCE_62)
                    }
                }
                .disabled(isLoading)
                Spacer()
            }
            .frame(width: 400, height: 60)
        }.padding([.leading, .trailing], -10)
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
        
        if isOfflineMode {
            if let cachedOrder = fetchOrderDetailFromCoreData(section: selectedSection, row: selectedRow, seat: selectedSeat) {
                self.order = OrdersNewApi(
                    buyerName: cachedOrder.buyer_name,
                    cc: cachedOrder.cc,
                    phone: cachedOrder.phone,
                    orderId: cachedOrder.oid?.intValue, valid: true, message: "",
                    seats: [SeatModel(section: "", row: "", seat: "", barcode: "", qrCode: "", qr: Qr(seat: [""]))],
                    merch: [Merchandise(name: "", variantName: "", qty: 0, icon: "", message: "", qr: QrMerchandise(merch: [""]), tsScanned: 0)]
                )
                self.showResultView = true
            }
            isLoading = false
            return
        }
        
        IQAPIClient.getSeatsResults(code: savedShowCode ?? "", section: selectedSection, row: selectedRow, seat: selectedSeat) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let orderDetail):
                    print("Order Details: \(orderDetail)")
                    self.orderDetails = orderDetail
                    self.order = OrdersNewApi(
                        buyerName: orderDetail.buyerName,
                        cc: orderDetail.cc,
                        phone: nil,
                        orderId: orderDetail.oid, valid: true, message: "",
                        seats: [SeatModel(section: "", row: "", seat: "", barcode: "", qrCode: "", qr: Qr(seat: [""]))],
                        merch: [Merchandise(name: "", variantName: "", qty: 0, icon: "", message: "", qr: QrMerchandise(merch: [""]), tsScanned: 0)]
                    )
                    
                    Task {
                        await lookupByOrderViewModel.fetchSeats(c: savedShowCode ?? "", q: String(orderDetails.oid ?? 24241))
                    }
                    self.showResultView = true
                    
                case .failure(let error):
                    print("Failed to fetch seat details: \(error.localizedDescription)")
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
                orderDetails.oid = seat.order_id?.intValue
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
            .listRowBackground(Color.white)
            .frame(height: 100)
            
            SeatRowLookupCell(action: {
                isRowLookupPresented = true
            }, selectedSeat: selectedRow)
            .listRowBackground(Color.white)
            .frame(height: 100)
            
            SeatLookupCell(action: {
                isSeatLookupPresented = true
            }, selectedSeat: selectedSeat)
            .listRowBackground(Color.white)
            .frame(height: 100)
        }.listStyle(.plain)
        
            .padding(0)
            .background(Color.customWhite)
    }
}

struct SeatLookupView_Previews: PreviewProvider {
    static var previews: some View {
        SeatLookupView(isPresented: .constant(false))
    }
}
