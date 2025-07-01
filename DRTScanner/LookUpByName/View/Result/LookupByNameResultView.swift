//
//  LookupByNameResultView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 17/02/25.
//

import SwiftUI

// View to display lookup results by name
struct LookupByNameResultView: View {
    let inputText: String // Input text for searching orders
    var dismissAction: () -> Void // Action to dismiss the view
    @StateObject private var viewModel = LookupByNameResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext) // ViewModel for fetching and holding orders
    @State var orders: [OrdersNewApi] = [] // Holds fetched orders
    let errorMessage: String? // Error message to display if any
    @State private var oId: String? // Selected order ID
    @State private var selectedOrder: OrdersNewApi? // Selected order object
    @State private var navigateToOrderResult = false // Controls navigation to order result view
    @AppStorage("showCode") private var savedShowCode: String? // Saved show code from app storage
    @State private var showTextAfterDelay = false // Controls delayed text display (not used in this snippet)
    @EnvironmentObject var stringManager: StringManager
    
    var body: some View {
        VStack {
                VStack {
                    HStack(alignment: .center) {
                        // Back button to dismiss the view
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dismissAction()
                            }
                        }) {
                            Image(StringConstants.DRTImages.leftSideArrow)
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        // Loading indicator and text
                        if viewModel.isLoading {
                            Text(viewModel.isLoading ? "Loading..." : "")
                                .foregroundColor(Color.customWhite)
                                .font(.verlagBlackAdaptive(size: 25))
                                .padding(.trailing, 20)
                            ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            }
                        // Display total results or no orders found
                        if !viewModel.isLoading {
                            
                            Text(viewModel.orders.isEmpty ? StringConstants.Common.noOrdersFound : (stringManager.strings?.searchResults.totalResults ?? "TOTAL RESULTS:") + " \(viewModel.orders.count)")
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
                    // If no orders, show spacer; else, show list of orders
                    if viewModel.orders.isEmpty {
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.orders, id: \.orderId) { order in
                                // Each order cell, tap to select and navigate
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
            // Fetch orders when view appears
            await viewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
            self.orders = viewModel.orders
        }
        // Custom sheet to show order result details
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
