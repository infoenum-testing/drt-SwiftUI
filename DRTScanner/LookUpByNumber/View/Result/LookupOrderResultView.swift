//
//  LookupOrderResultView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//

import SwiftUI
import CoreData

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
            VStack {
                HStack (alignment: .center){
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            dismissAction()
                        }
                    }) {
                        Image(StringConstants.DRTImages.leftSideArrow)
                            .foregroundStyle(Color.neutralText)
                            .padding(10.adaptiveForIpad)
                    }.padding(.leading, 10)
                    
                    Spacer()
                    if viewModel.isLoading {
                        Text(viewModel.isLoading ? stringManager.strings?.searchResults.loading ?? "Loading..." : "")
                            .foregroundStyle(Color.neutralText)
                            .font(.verlagBlackAdaptive(size: 25))
                            .padding(.trailing, 20)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                            .padding(.trailing, 5)
                        Spacer()
                    }
                    if !viewModel.isLoading {
                        if let buyerName = viewModel.buyerName {
                            Text(buyerName.uppercased())
                                .foregroundStyle(Color.neutralText)
                                .font(.verlagBlackAdaptive(size: 25))
                                .padding(.trailing, 20)
                        } else {
                            Text(stringManager.strings?.searchResults.resultNotFound ?? StringConstants.Common.noOrdersFound )
                                .foregroundStyle(Color.neutralText)
                                .font(.verlagBlackAdaptive(size: 25))
                                .padding(.trailing, 20)
                        }
                        Spacer()
                    }
                }
                if !viewModel.isLoading {
                    if let _ = viewModel.buyerName , let order {
                        HStack(alignment: .center) {
                            Text("\(stringManager.strings?.searchResults.order ?? StringConstants.Common.Order): \(String(order.orderId ?? 0))")
                                .font(.verlagBoldAdaptive(size: 15))
                                .foregroundColor(Color.neutralText)
                            Text("\(stringManager.strings?.searchResults.cc ?? StringConstants.LandingView.ccLabel)" + " \(order.cc ?? "")")
                                .font(.verlagBoldAdaptive(size: 15))
                                .foregroundColor(Color.neutralText)
                        }
                    }
                }
            }.padding([.bottom, .top])
                .background(Color.neutralBg)
                .frame(maxWidth: .infinity)
            VStack {
                // Merchandise section (online/offline)
                if let isMerchandise, isMerchandise {
                    if isOfflineMode {
                        if isLoadingMerch {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                                .padding()
                            Spacer()
                        }
                        else if !products.isEmpty {
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
                            Text(stringManager.strings?.searchResults.nomerchandiseFound ?? "No merchandise found.")
                                .foregroundColor(Color.neutralText)
                            Spacer()
                        }
                    } else {
                        
                        if isLoadingMerch {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                                .padding()
                            Spacer()
                        }
                        else {
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
                        }
                    }
                } else {
                    // Seat section
                    if viewModel.isLoading {
                        Text(viewModel.isLoading ? stringManager.strings?.searchResults.loading ?? "Loading..." : "")
                            .foregroundColor(Color.primaryText)
                            .font(.verlagBlackAdaptive(size: 25))
                            .padding(.trailing, 20)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                            .padding(.trailing, 5)
                        Spacer()
                    }
                    if !viewModel.isLoading {
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
            isLoadingMerch = true
            await viewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
            self.seats = viewModel.seatsModel ?? []
            self.merch = viewModel.merchModel ?? []
            self.merchOrders = merch.map { MerchandiseOrder(from: $0) }
            
            if let orderId = order?.orderId {
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
