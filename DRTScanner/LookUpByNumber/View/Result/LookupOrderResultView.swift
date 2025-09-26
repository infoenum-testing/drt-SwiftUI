//
//  LookupOrderResultView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//

import SwiftUI
import CoreData
import Shimmer

// View to display the result of looking up an order by order number
struct LookupOrderResultView: View {
    let inputText: String // The input order number or code
    var dismissAction: () -> Void // Action to dismiss this view
    
    @StateObject private var viewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext) // ViewModel for fetching order data
    @State private var seats: [SeatModel] = [] // List of seat models for the order
    @State private var merch: [Merchandise] = [] // List of merchandise for the order
    @State private var merchOrders: [MerchandiseOrder] = []
    @State private var productOrders: [MerchandiseOrder] = []
    
    @AppStorage("showCode") private var savedShowCode: String? // Saved show code from user defaults
    @AppStorage("isMerchandise") private var isMerchandise: Bool? // Flag to indicate merchandise mode
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false // Flag for offline mode
    @State private var isLoadingMerch = true // Loading state for merchandise
    @State  var errorMessages: String? = nil // Error message for alert
    let errorMessage: String? // Error message passed in
    var order: OrdersNewApi? // Order object
    @EnvironmentObject var stringManager: StringManager
    @State private var products: [Product] = [] // List of products (for offline mode)
    
    var body: some View {
        VStack {
            // Header section with back button and order/buyer info
            HStack (alignment: .center) {
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
                VStack(spacing: 10.adaptiveForIpad) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.secondaryText)
                            .frame(width: 180.adaptiveForIpad, height: 30.adaptiveForIpad)
                            .shimmering(active: true, gradient: Gradient(colors: [Color.neutralText.opacity(0.3),
                                                                                  Color.neutralText,
                                                                                  Color.neutralText.opacity(0.3)])
                            )
                            .padding(.trailing, 20)
                            .opacity(viewModel.isLoading ? 1 : 0)
                        if !viewModel.isLoading {
                            if let buyerName = viewModel.buyerName {
                                CustomsText(title: buyerName.uppercased(), textFont: .verlagBlackAdaptive(size: 25), foregroundColour: .neutralText)
                                    .padding(.trailing, 20)
                            } else {
                                CustomsText(title: stringManager.strings.searchResults.resultNotFound, textFont: .verlagBlackAdaptive(size: 25), foregroundColour: .neutralText)
                                    .padding(.trailing, 20)
                            }
                        }
                    }
                    if !viewModel.isLoading {
                        if let _ = viewModel.buyerName , let order = viewModel.orders.first {
                            HStack(alignment: .center) {
                                CustomsText(title: "\(stringManager.strings.searchResults.order): \(String(order.orderId ?? 0))", textFont: .verlagBoldAdaptive(size: 15), foregroundColour: Color.neutralText)
                                
                                CustomsText(title: "\(stringManager.strings.searchResults.cc)" + " \(order.cc ?? "")", textFont: .verlagBoldAdaptive(size: 15), foregroundColour: .neutralText)
                            }
                        }
                    }
                    
                }
                Spacer()
                
            }
            .padding(.horizontal,15.adaptiveForIpad)
            .frame(maxHeight: 90.adaptiveForIpad)
            .background(Color.neutralBg)
            
            VStack {
                // Merchandise section (online/offline)
                if let isMerchandise, isMerchandise {
                    if isOfflineMode {
                        if isLoadingMerch {
                            ScrollView {
                                LazyVStack {
                                    ForEach(0..<8) { order in
                                        MerchandiseOrderShimmerView()
                                    }
                                }
                                .padding(.bottom)
                            }
                            .padding(0)
                        } else if !products.isEmpty {
                            ScrollView {
                                LazyVStack {
                                    ForEach(productOrders) { order in
                                        MerchandiseOrderCell(
                                            merchandiseOrder: order,
                                            lookupByOrderResultViewModel: viewModel,
                                            showAlert: $stringManager.isShowAlert
                                        )
                                    }
                                }
                                .padding(.bottom)
                            }
                            .padding(0)
                        } else {
                            Text(stringManager.strings.searchResults.nomerchandiseFound)
                                .foregroundColor(Color.neutralText)
                            Spacer()
                        }
                    } else {
                        if isLoadingMerch {
                                ScrollView {
                                    LazyVStack {
                                        ForEach(0..<8) { order in
                                            MerchandiseOrderShimmerView()
                                        }
                                    }
                                    .padding(.bottom)
                                    .padding(.horizontal)
                                }
                        } else if !merchOrders.isEmpty {
                            ScrollView {
                                LazyVStack {
                                    ForEach(merchOrders) { order in
                                        MerchandiseOrderCell(
                                            merchandiseOrder: order,
                                            lookupByOrderResultViewModel: viewModel,
                                            showAlert: $stringManager.isShowAlert
                                        )
                                      
                                    }
                                }
                                .padding(.bottom)
                                .padding(.horizontal)
                            }
                        } else {
                            Text(stringManager.strings.searchResults.nomerchandiseFound)
                                .foregroundColor(Color.neutralText)
                            Spacer()
                        }
                    }
                } else {
                    //MARK:  Seat section
                    if viewModel.isLoading {
                        ScrollView {
                            LazyVStack {
                                ForEach(0..<8, id: \.self) { _ in
                                    SeatCellShimmerView()
                                        .background(Color.primaryText)
                                }
                            }
                            .padding(.bottom)
                            .padding(.horizontal)
                        }
                    } else {
                        ScrollView {
                            LazyVStack {
                                ForEach(seats.indices, id: \.self) { index in
                                    SeatCell(seat: $seats[index], showAlert: $stringManager.isShowAlert, lookupByOrderResultViewModel: viewModel)
                                        .background(Color.primaryText)
                                }
                            }
                            .padding(.bottom)
                            .padding(.horizontal)
                        }
                        
                    }
                }
            }
        }
        .background(Color.primaryText)
        .task {
            // Fetch seats and merchandise when view appears
            try? await Task.sleep(nanoseconds: 200_000_000)
            isLoadingMerch = true
            await viewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
            self.seats = viewModel.seatsModel ?? []
            self.merch = viewModel.merchModel ?? []
            self.merchOrders = merch.map { MerchandiseOrder(from: $0) }
            
            if let orderId = viewModel.orders.first?.orderId {
                fetchProducts(orderId: orderId)
            }
            isLoadingMerch = false
        }
        .onChange(of: viewModel.errorMessage, perform: { newValue in
            stringManager.message = newValue ?? "This"
        })
        .edgesIgnoringSafeArea(.all)
    }
    
    // Fetch products from Core Data for offline merchandise display
    @MainActor
    private func fetchProducts(orderId: Int) {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "orderId == %@", NSNumber(value: orderId))
        
        do {
            let fetchedProducts = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
            self.products = fetchedProducts
            self.productOrders = fetchedProducts.map { MerchandiseOrder(from: $0) } // ✅ Track these for UI
        } catch {
            print("Error fetching products: \(error)")
        }
    }
}
