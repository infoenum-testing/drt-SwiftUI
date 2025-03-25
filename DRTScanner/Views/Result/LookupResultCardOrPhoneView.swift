//
//  LookupResultCardOrPhoneView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI

struct LookupResultCardOrPhoneView: View {
    @AppStorage("showCode") private var savedShowCode: String?
    let inputText: String
    var dismissAction: () -> Void
    @StateObject private var creditCardViewModel = LookupByCreditCardResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @StateObject private var phoneViewModel = LookupByPhoneResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @StateObject private var viewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @State private var isSheetPresented: Bool = false
    var orders: [OrdersNewApi] {
           lookupType == .phoneNumber ? phoneViewModel.orders : creditCardViewModel.orders
       }

    let errorMessage: String?
    let lookupType: LookupType
    
    @State private var oId: String?
    
    @State private var selectedOrder: OrdersNewApi?
    @State private var navigateToOrderResult = false

    var body: some View {
        VStack {
                VStack {
                    HStack(alignment: .center) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dismissAction()
                            }
                        }) {
                            Image("left_side_arrow")
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        Text(!viewModel.orders.isEmpty ? "Total Results: \(viewModel.orders.count)" : "No orders found")
                            .foregroundColor(Color.customWhite)
                            .font(Font.custom("Verlag-Black", size: 25))
                            .padding(.trailing, 20)
                        Spacer()
                    }
                }
               .padding([.top, .bottom], 20)
                .background(Color.FFCE_62)
                .frame(maxWidth: .infinity)

                VStack {
                    if orders.isEmpty {
                        Spacer()
                    } else {
                        List {
                            ForEach(orders, id: \.orderId) { seat in
                                LookupCellView(result: seat) { orderId in
                                    selectedOrder = seat
                                    oId = "\(orderId)"
                                    navigateToOrderResult = true
                                }.listRowBackground(Color.white)
                            }
                        }
                        .listStyle(.plain)
                        .padding(0)
                    }
                }
            }
        .frame(maxHeight: .infinity)
        .background(Color.customWhite)
        .ignoresSafeArea()
        .task {
            if lookupType == .phoneNumber {
                await phoneViewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
            } else {
                await creditCardViewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
            }
        }
        .customSheetView(isPresented: $navigateToOrderResult) {
            if let selectedOrder = selectedOrder {
                LookupOrderResultView(inputText: oId ?? "", dismissAction: { navigateToOrderResult = false }, errorMessage: nil, order: selectedOrder)
            }
                    }.padding(.top, 40)
        .onChange(of: navigateToOrderResult) { newValue in
            print(newValue)
        }
    }
}
