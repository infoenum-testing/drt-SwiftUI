//
//  LookupResultCardOrPhoneView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI

/// View for displaying lookup results either by Credit Card or Phone Number.
struct LookupResultCardOrPhoneView: View {
    
    // MARK: - App Storage
    @AppStorage("showCode") private var savedShowCode: String?
    
    // MARK: - Input Parameters
    let inputText: String
    var dismissAction: () -> Void
    
    // MARK: - View Models
    @StateObject private var creditCardViewModel = LookupByCreditCardResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @StateObject private var phoneViewModel = LookupByPhoneResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @StateObject private var viewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext) // Currently unused
    
    // MARK: - State
    @State private var isSheetPresented: Bool = false            // Controls presentation of bottom sheet (not used directly here)
    @State private var oId: String?                              // Selected order ID (used when navigating to order detail)
    @State private var selectedOrder: OrdersNewApi?              // Holds the selected order model
    @State private var navigateToOrderResult = false             // Controls custom sheet navigation
    @EnvironmentObject var stringManager: StringManager
    
    // MARK: - Input Error & Type
    let errorMessage: String?                                    // Not used inside this view currently
    let lookupType: LookupType                                   // Determines if lookup is by phone number or credit card
    
    // MARK: - Computed Properties
    // Computed property to return the right list of orders based on lookup type
    var orders: [OrdersNewApi] {
        lookupType == .phoneNumber ? phoneViewModel.orders : creditCardViewModel.orders
    }
    
    // Computed property to return loading state based on lookup type
    var isLoading: Bool {
        lookupType == .phoneNumber ? phoneViewModel.isLoading : creditCardViewModel.isLoading
    }
    
    // MARK: - View
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                // Back button to dismiss view
                Button(action: {
                    withAnimation {
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
                
                // Show loading text & spinner
                if isLoading {
                    Text(stringManager.strings.searchResults.loading)
                        .foregroundStyle(Color.neutralText)
                        .font(.verlagBlackAdaptive(size: 25))
                        .padding(.trailing, 20)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                }
                
                // Show result count or "No orders found"
                if !isLoading {
                    Text(orders.isEmpty ? stringManager.strings.searchResults.resultNotFound : (stringManager.strings.searchResults.totalResults) + " \(orders.count)")
                        .foregroundStyle(Color.neutralText)
                        .font(.verlagBlackAdaptive(size: 25))
                        .padding(.trailing, 20)
                }
                Spacer()
            }
            .padding(.horizontal,15.adaptiveForIpad)
            .frame(maxHeight: 90.adaptiveForIpad)
            .background(Color.neutralBg)
            
            // Orders List or Empty View
            VStack {
                if orders.isEmpty {
                    Spacer() // Empty space if no orders found
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(orders, id: \.orderId) { seat in
                                LookupCellView(result: seat) { orderId in
                                    selectedOrder = seat
                                    oId = "\(orderId)"
                                    withAnimation {
                                        navigateToOrderResult = true
                                    }// Store selected order ID
                                       // Trigger sheet
                                }
                                .background(Color.primaryText)
                            }
                        }
                    }
                    .padding(0)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color.primaryText)
        .ignoresSafeArea()
        
        // MARK: - Task: Initial API call
        .task {
            // Sleep for 0.2 seconds (200_000_000 nanoseconds)
            try? await Task.sleep(nanoseconds: 200_000_000)

            if lookupType == .phoneNumber {
                await phoneViewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
            } else {
                await creditCardViewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
            }
        }
        
        // MARK: - Sheet View for Order Detail
        .overlay {
            if navigateToOrderResult {
                if let selectedOrder = selectedOrder {
                    LookupOrderResultView(
                        inputText: oId ?? "",
                        dismissAction: {
                            withAnimation {
                                navigateToOrderResult = false
                            }
                        },
                        errorMessage: nil,
                        order: selectedOrder
                    )
                    .transition(.move(edge: .trailing))
                }
            }
        }
        .padding(.top, 0)
        // Optional: Debug print for sheet presentation
        .onChange(of: navigateToOrderResult) { newValue in
            print(newValue)
        }
    }
}
