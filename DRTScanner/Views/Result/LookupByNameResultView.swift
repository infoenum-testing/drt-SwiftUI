//
//  LookupByNameResultView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/02/25.
//

import SwiftUI

struct LookupByNameResultView: View {
    let inputText: String
    var dismissAction: () -> Void
    @StateObject private var viewModel = LookupByNameResultViewModel()
    @State private var orders: [Orders] = []
    let errorMessage: String?
    let order: Orders

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
                .padding()
                .background(Color.showCodeButton)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .padding([.bottom, .top])
                .background(Color.showCodeButton)
                .frame(maxWidth: .infinity)

                VStack {
                    if orders.isEmpty {
                        Text("Loading Order information...")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(orders, id: \.orderId) { seat in
                                LookupCellView(result: order) { orderId in
                                    Task {
                                    //    await viewModel.fetchSeats(c: "289-6385", q: String(order.orderId ?? 0))
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.customWhite)
      //  .ignoresSafeArea()
        .task {
            await viewModel.fetchSeats(c: "289-6385", q: inputText)
            self.orders = viewModel.orders
        }
    }
}
//
//
//struct LookupNameCellView: View {
//    var result: Orders
//    
//    var body: some View {
//        VStack(alignment: .center) {
//            Text(result.buyerName ?? "")
//                .font(.custom("Verlag-Black", size: 24))
//                .foregroundColor(Color.showCodeText)
//                .frame(maxWidth: .infinity, alignment: .center)
//                .padding(.top, 20)
//
//            HStack {
//
//                Text("ORDER: \(result.orderId ?? 0)")
//                    .font(.custom("Verlag-Bold", size: 15))
//                    .foregroundColor(Color.showCodeText)
//                
//                Text("CC: \(result.cc ?? "")")
//                    .font(.custom("Verlag-Bold", size: 15))
//                    .foregroundColor(Color.showCodeText)
//            }
//            .padding(.top, 5)
//
//            Text("PHONE NUMBER: \(result.phone ?? "")")
//                .font(.custom("Verlag-Bold", size: 15))
//                .foregroundColor(Color.showCodeText)
//                .frame(maxWidth: .infinity, alignment: .center)
//                .padding(.top, 10)
//        }
//        .padding(10)
//    }
//}
