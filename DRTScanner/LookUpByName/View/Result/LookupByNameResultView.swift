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
            HStack(alignment: .center) {
                // Back button to dismiss the view
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        dismissAction()
                    }
                }) {
                    Image(StringConstants.DRTImages.leftSideArrow)
                        .resizable()
                        .frame(width: 20.adaptiveForIpad, height: 30.adaptiveForIpad, alignment: .center)
                        .foregroundStyle(Color.neutralText)
                        .padding(10.adaptiveForIpad)
                }
                
                Spacer()
                // Loading indicator and text
                if viewModel.isLoading {
                    CustomsText(title: stringManager.strings.searchResults.loading, textFont: .verlagBlackAdaptive(size: 25), foregroundColour: .neutralText)
                        .padding(.trailing, 20)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                        .padding(.trailing, 5)
                }
                // Display total results or no orders found
                if !viewModel.isLoading {
                    CustomsText(title: viewModel.orders.isEmpty ? stringManager.strings.searchResults.resultNotFound : (stringManager.strings.searchResults.totalResults) + " \(viewModel.orders.count)", textFont: .verlagBlackAdaptive(size: 25), foregroundColour: .neutralText)
                        .padding(.trailing, 20)
                }
                Spacer()
            }
                .padding(.horizontal,15.adaptiveForIpad)
                .frame(maxHeight: 90.adaptiveForIpad)
                .background(Color.neutralBg)
            VStack {
                // If no orders, show spacer; else, show list of orders
                if viewModel.orders.isEmpty {
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.orders, id: \.orderId) { order in
                                // Each order cell, tap to select and navigate
                                LookupCellView(result: order) { orderId in
                                    selectedOrder = order
                                    oId = "\(orderId)"
                                    withAnimation{
                                        navigateToOrderResult = true
                                    }
                                }.background(Color.primaryText)
                            }
                        }
                        .padding(.bottom)
                    }
                    .padding(0)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.primaryText)
        .task {
            // Fetch orders when view appears
            try? await Task.sleep(nanoseconds: 2_000_000_00)
            await viewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
            self.orders = viewModel.orders
        }
        .overlay {
            if navigateToOrderResult {
                if let selectedOrder = selectedOrder {
                    LookupOrderResultView(inputText: oId ?? "", dismissAction: { navigateToOrderResult = false }, errorMessage: nil, order: selectedOrder)
                        .padding(.top, 0)
                        .transition(.move(edge: .trailing))
                }
            }
        }
       
    }
}
