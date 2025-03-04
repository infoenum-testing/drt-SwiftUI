//
//  LookupByNameResultView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/02/25.
//

import SwiftUI
//
//struct LookupByNameResultView: View {
//    let inputText: String
//    var dismissAction: () -> Void
//    @StateObject private var viewModel = LookupByNameResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
//    @State var orders: [Orders]
//    let errorMessage: String?
//
//    var body: some View {
//        VStack {
//            if let errorMessage = errorMessage {
//                VStack {
//                    HStack {
//                        Button(action: {
//                            withAnimation(.easeInOut(duration: 0.3)) {
//                                dismissAction()
//                            }
//                        }) {
//                            Image("left_side_arrow")
//                        }
//                        .padding(.leading, 20)
//                        
//                        Spacer()
//                        
//                        Text(errorMessage)
//                            .foregroundColor(Color.customWhite)
//                            .font(Font.custom("Verlag-Bold", size: 30))
//                            .padding(.trailing, 20)
//                        Spacer()
//                    }
//                        
//                }
//                .padding()
//                .background(Color.showCodeButton)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//            } else {
//                VStack {
//                    HStack(alignment: .center) {
//                        Button(action: {
//                            withAnimation(.easeInOut(duration: 0.3)) {
//                                dismissAction()
//                            }
//                        }) {
//                            Image("left_side_arrow")
//                        }
//                        .padding(.leading, 20)
//                        
//                        Spacer()
//                        Text("Total Results:")
//                            .foregroundColor(Color.customWhite)
//                            .font(Font.custom("Verlag-Black", size: 25))
//                            .padding(.trailing, 20)
//                        Spacer()
//                    }
//                }
//                .padding([.bottom, .top])
//                .background(Color.showCodeButton)
//                .frame(maxWidth: .infinity)
//
//                VStack {
//                    if orders.isEmpty {
//                        Spacer()
//                    } else {
//                        List {
//                            ForEach(orders, id: \.orderId) { seat in
//                                LookupCellView(result: seat) { orderId in
//                                    Task {
//                                    //    await viewModel.fetchSeats(c: "289-6385", q: String(order.orderId ?? 0))
//                                    }
//                                }
//                            }
//                        }
//                        .listStyle(.plain)
//                        .padding(0)
//                    }
//                }
//            }
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .background(Color.customWhite)
//      //  .ignoresSafeArea()
//        .task {
//            await viewModel.fetchSeats(c: "289-6385", q: inputText)
//            self.orders = viewModel.orders
//        }
//    }
//}

struct LookupByNameResultView: View {
    let inputText: String
    var dismissAction: () -> Void
    @StateObject private var viewModel = LookupByNameResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @State var orders: [Orders] = []
    let errorMessage: String?
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
                    if viewModel.orders.isEmpty {
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.orders, id: \.orderId) { order in
                                LookupCellView(result: order) { orderId in
                                    selectedOrder = order
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.customWhite)
        .task {
            await viewModel.fetchSeats(c: "289-6385", q: inputText)
            self.orders = viewModel.orders
        }
        .customSheetView(isPresented: $navigateToOrderResult) {
            if let selectedOrder = selectedOrder {
                LookupOrderResultView(inputText: oId ?? "", dismissAction: { navigateToOrderResult = false }, errorMessage: nil, order: selectedOrder)
            }
        }.padding(.top, 0)
        .onChange(of: navigateToOrderResult) { newValue in
            print(newValue)
        }
    }
}
