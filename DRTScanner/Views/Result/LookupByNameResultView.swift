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
    @StateObject private var viewModel = LookupByNameResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @State var orders: [OrdersNewApi] = []
    let errorMessage: String?
    @State private var oId: String?
    @State private var selectedOrder: OrdersNewApi?
    @State private var navigateToOrderResult = false
    @AppStorage("showCode") private var savedShowCode: String?
    @State private var showTextAfterDelay = false

    var body: some View {
        VStack {
                VStack {
                    HStack(alignment: .center) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dismissAction()
                            }
                        }) {
                            Image(StringConstants.DRTImages.leftSideArrow)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        if viewModel.isLoading {
                            Text(viewModel.isLoading ? "Loading..." : "")
                                .foregroundColor(Color.customWhite)
                                .font(.verlagBlackAdaptive(size: 25))
                                .padding(.trailing, 20)
                            ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                        if !viewModel.isLoading {
                            
                            Text(viewModel.orders.isEmpty ? StringConstants.Common.noOrdersFound : "Total Results: \(viewModel.orders.count)")
                                .foregroundColor(Color.customWhite)
                                .font(.verlagBlackAdaptive(size: 25))
                                .padding(.trailing, 20)
                        }
                        Spacer()
                    }
                }
                .padding([.bottom, .top])
                .background(Color.FFCE_62)
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
                                }.listRowBackground(Color.white)
                            }
                        }
                        .listStyle(.plain)
                        .padding(0)
                    }
                }
            }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.customWhite)
        .task {
            await viewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
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
