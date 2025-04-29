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
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }) {
                        Image(StringConstants.DRTImages.leftSideArrow)
                    }.padding(.leading, 20)
                    
                    //TextField("", text: $seatText)
                    TextField("", text: $seatText, prompt: Text("Select Seat").font(.verlagBoldAdaptive(size: 30)).foregroundColor(Color.black.opacity(0.2)))
                        .font(.verlagBoldAdaptive(size: 42))
                        .foregroundColor(.customWhite)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.clear)
                        .multilineTextAlignment(.center)
                        .padding(.leading, -50)
                        .disabled(true)
                        .onChange(of: selectedSection) { _ in seatText = seatDisplayText }
                        .onChange(of: selectedRow) { _ in seatText = seatDisplayText }
                        .onChange(of: selectedSeat) { _ in seatText = seatDisplayText }
                }
                .frame(maxWidth: .infinity, maxHeight: 90.adaptiveForIpad)
                .background(Color.FFCE_62)
                
                TableView(
                    isSeatLookupPresented: $isSeatLookupPresented,
                    isSectionLookupPresented: $isSectionLookupPresented,
                    isRowLookupPresented: $isRowLookupPresented,
                    selectedSection: $selectedSection,
                    selectedRow: $selectedRow,
                    selectedSeat: $selectedSeat
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                
                HStack {
                    Spacer()
                    Button(action: {
                        continueButtonTapped()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1)
                        } else {
                            VStack {
                                Text(StringConstants.Common.continueText)
                                    .font(.verlagBoldAdaptive(size: 36))
                                    .foregroundColor(.customWhite)
                                    .padding(.top, 5.adaptiveForIpad)  
                            }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.FFCE_62)
                        }
                    }
                    .disabled(isLoading)
                    .disabled(selectedSeat.isEmpty)
                    .opacity(selectedSeat.isEmpty ? 0.6 : 1.0)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.08)
                .padding(.bottom, UIScreen.main.bounds.height * 0.05)
                .edgesIgnoringSafeArea(.all)
                .background(Color.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
        }
        .customSheetView(isPresented: $showResultView) {
            LookupOrderResultView(
                inputText: String(orderDetails.oid ?? 24241),
                dismissAction: { showResultView = false },
                errorMessage: nil,
                order: order
            )
        }
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
                    orderId: cachedOrder.oid?.intValue,
                    valid: true,
                    goldenTicketText: "",
                    isGoldenTicket: nil,
                    message: "",
                    seats: [],
                    merch: []
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
                        orderId: orderDetail.oid,
                        valid: true,
                        goldenTicketText: "",
                        isGoldenTicket: nil,
                        message: "",
                        seats: [],
                        merch: []
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

struct SeatLookupView_Previews: PreviewProvider {
    static var previews: some View {
        SeatLookupView(isPresented: .constant(false))
    }
}
