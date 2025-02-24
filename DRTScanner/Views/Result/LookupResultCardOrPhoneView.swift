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
    @StateObject private var creditCardViewModel = LookupByCreditCardResultViewModel()
    @StateObject private var phoneViewModel = LookupByPhoneResultViewModel()
    @StateObject private var viewModel = LookupByOrderResultViewModel()
    @State private var isSheetPresented: Bool = false
    @State var orders: [Orders]
    let errorMessage: String?
    let lookupType: LookupType

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
//                        Text("Loading Order information...")
//                            .foregroundColor(.gray)
//                            .padding()
                        Spacer()
                    } else {
                        List {
                            ForEach(orders, id: \.orderId) { seat in
                                LookupCellView(result: seat) { orderId in
                                    Task {
//                                        await viewModel.fetchSeats(c: "289-6385", q: String(24241))
//                                        isSheetPresented = true
                                    }
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
                self.orders = phoneViewModel.orders
            } else {
                await creditCardViewModel.fetchSeats(c: "289-6385", q: inputText)
                self.orders = creditCardViewModel.orders
            }
        }
    }
}
