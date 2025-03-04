//
//  LookupResultCardOrPhoneView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI

struct LookupResultCardOrPhoneView: View {
    let inputText: String
    var dismissAction: () -> Void
    @StateObject private var creditCardViewModel = LookupByCreditCardResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @StateObject private var phoneViewModel = LookupByPhoneResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @StateObject private var viewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @State private var isSheetPresented: Bool = false
    var orders: [Orders] {
           lookupType == .phoneNumber ? phoneViewModel.orders : creditCardViewModel.orders
       }

    let errorMessage: String?
    let lookupType: LookupType
    
    @State private var oId: String?
    
    @State private var selectedOrder: Orders?
    @State private var navigateToOrderResult = false

    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                VStack {
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dismissAction()
                            }
                        }) {
                            Image("left_side_arrow")
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text(errorMessage)
                            .foregroundColor(Color.customWhite)
                            .font(Font.custom("Verlag-Bold", size: 30))
                            .padding(.trailing, 20)
                        
                        Spacer()
                    }
                }
                .padding([.top, .bottom], 50)
                .background(Color.showCodeButton)
                .frame(maxWidth: .infinity)
            } else {
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
                        Text("Total Results:")
                            .foregroundColor(Color.customWhite)
                            .font(Font.custom("Verlag-Black", size: 25))
                            .padding(.trailing, 20)
                        Spacer()
                    }
                }
               .padding([.top, .bottom], 20)
                .background(Color.showCodeButton)
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
                                }
                            }
                        }
                        .listStyle(.plain)
                        .padding(0)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color.customWhite)
        .ignoresSafeArea()
        .task {
            if lookupType == .phoneNumber {
                await phoneViewModel.fetchSeats(c: "289-6385", q: inputText)
              //  self.orders = phoneViewModel.orders
            } else {
                await creditCardViewModel.fetchSeats(c: "289-6385", q: inputText)
             //   self.orders = creditCardViewModel.orders
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
