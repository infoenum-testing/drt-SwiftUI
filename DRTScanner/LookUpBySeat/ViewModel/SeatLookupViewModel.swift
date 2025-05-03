//
//  SeatLookupViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/05/25.
//

import Foundation
import SwiftUI
import CoreData
import IQAPIClient

class SeatLookupViewModel: ObservableObject {
    @Published var selectedSection = ""
    @Published var selectedRow = ""
    @Published var selectedSeat = ""
    @Published var seatText = ""
    @Published var isLoading = false
    @Published var showResultView = false
    @Published var errorMessage: String? = nil
    @Published var order: OrdersNewApi? = nil
    @Published var orderDetails = OrderDetailModel()
    
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    
    private var viewContext: NSManagedObjectContext
    private var lookupByOrderViewModel: LookupByOrderResultViewModel

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        self.lookupByOrderViewModel = LookupByOrderResultViewModel(managedObjectContext: context)
    }
    
    var seatDisplayText: String {
        [selectedSection, selectedRow, selectedSeat].filter { !$0.isEmpty }.joined(separator: " - ")
    }

    func onSeatDataChanged() {
        seatText = seatDisplayText
    }

    func continueButtonTapped() {
        guard !selectedSection.isEmpty, !selectedRow.isEmpty, !selectedSeat.isEmpty else {
            errorMessage = "Please select a section, row, and seat before continuing."
            return
        }

        isLoading = true

        if isOfflineMode {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                if let cachedOrder = self.fetchOrderDetailFromCoreData() {
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
                    self.errorMessage = nil
                } else {
                    self.order = nil
                    self.errorMessage = "No orders found"
                }
                self.showResultView = true
                self.isLoading = false
            }
        } else {
            IQAPIClient.getSeatsResults(code: savedShowCode ?? "", section: selectedSection, row: selectedRow, seat: selectedSeat) { result in
                DispatchQueue.main.async {
                    self.isLoading = false
                    switch result {
                    case .success(let orderDetail):
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
                            await self.lookupByOrderViewModel.fetchSeats(c: self.savedShowCode ?? "", q: String(orderDetail.oid ?? 0))
                        }
                        self.showResultView = true
                    case .failure(let error):
                        self.errorMessage = "Failed to fetch seat details: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    private func fetchOrderDetailFromCoreData() -> Order? {
        let request: NSFetchRequest<Seat> = Seat.fetchRequest()
        request.predicate = NSPredicate(format: "section == %@ AND row == %@ AND seat == %@", selectedSection, selectedRow, selectedSeat)

        do {
            let results = try viewContext.fetch(request)
            if let seat = results.first {
                self.orderDetails.oid = seat.order_id?.intValue
                return seat.order
            }
        } catch {
            print("Core Data fetch error: \(error.localizedDescription)")
        }
        return nil
    }
}
