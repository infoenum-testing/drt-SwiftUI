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
    @AppStorage("showCode") private var savedShowCode: String? // Saved show code from user defaults
    @AppStorage("isMerchandise") private var isMerchandise: Bool? // Flag to indicate merchandise mode
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false // Flag for offline mode
    @State private var isLoadingMerch = true // Loading state for merchandise
    @State private var showAlert = false // State to show/hide error alert
    @State  var errorMessages: String? = nil // Error message for alert
    let errorMessage: String? // Error message passed in
    var order: OrdersNewApi? // Order object
    
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
                    }.padding(.leading, 20)
                    
                    Spacer()
                    if viewModel.isLoading {
                        Text(viewModel.isLoading ? "Loading..." : "")
                            .foregroundColor(Color.customWhite)
                            .font(.verlagBlackAdaptive(size: 25))
                            .padding(.trailing, 20)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .padding(.trailing, 5)
                        Spacer()
                    }
                    if !viewModel.isLoading {
                        Text(viewModel.buyerName == "No orders found" ? StringConstants.Common.noOrdersFound : viewModel.buyerName.uppercased())
                            .foregroundColor(Color.customWhite)
                            .font(.verlagBlackAdaptive(size: 25))
                            .padding(.trailing, 20)
                        Spacer()
                    }
                }
                if !viewModel.isLoading {
                    if viewModel.buyerName != "No orders found" {
                    HStack(alignment: .center) {
                        Text("\(StringConstants.Common.Order) \(order?.orderId ?? 0)")
                            .font(.verlagBoldAdaptive(size: 15))
                            .foregroundColor(Color.customWhite)
                        Text("CC \(order?.cc ?? "")")
                            .font(.verlagBoldAdaptive(size: 15))
                            .foregroundColor(Color.customWhite)
                    }
                }
            }
                }.padding([.bottom, .top])
                    .background(Color.FFCE_62)
                    .frame(maxWidth: .infinity)
            VStack {
                // Merchandise section (online/offline)
                if isMerchandise ?? false {
                    if isOfflineMode {
                        if isLoadingMerch {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                .padding()
                            Spacer()
                        }
                        else if !products.isEmpty {
                            List {
                                ForEach(products, id: \.self) { product in
                                    let merchandiseOrder = MerchandiseOrder(from: product)
                                    MerchandiseOrderCell(merchandiseOrder: merchandiseOrder)
                                }
                            }
                            .listStyle(.plain)
                                .padding(0)
                        } else {
                            Text("No merchandise found.")
                                .foregroundColor(Color.gray)
                            Spacer()
                        }
                    } else {
                        
                        if isLoadingMerch {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                .padding()
                            Spacer()
                        }
                        else {
                            List {
                                ForEach(merch.indices, id: \.self) { index in
                                    MerchandiseOrderCell(merchandiseOrder: MerchandiseOrder(from: merch[index]))
                                }
                            }.listStyle(.plain)
                                .padding(0)
                        }
                    }
                } else {
                    // Seat section
                    if viewModel.isLoading {
                        Text(viewModel.isLoading ? "Loading..." : "")
                            .foregroundColor(Color.customWhite)
                            .font(.verlagBlackAdaptive(size: 25))
                            .padding(.trailing, 20)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                .padding(.trailing, 5)
                        Spacer()
                        }
                    if !viewModel.isLoading {
                        List {
                            ForEach(seats.indices, id: \.self) { index in
                                SeatCell(seat: $seats[index], showAlert: $showAlert, lookupByOrderResultViewModel: viewModel)
                                    .listRowBackground(Color.white)
                            }
                        }.listStyle(.plain)
                            .padding(0)
                    }
                }
            }
        }
        .background(Color.customWhite)
        .task {
            // Fetch seats and merchandise when view appears
            isLoadingMerch = true
            await viewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
            self.seats = viewModel.seatsModel ?? []
            self.merch = viewModel.merchModel ?? []
           
            if let orderId = order?.orderId {
                fetchProducts(orderId: orderId)
            }
            isLoadingMerch = false
        }
        .customAlert(isPresented: $showAlert) {
            // Custom alert for error messages
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    Color.black.opacity(0)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAlert = false
                            }
                        }

                    VStack(alignment: .center) {
                        HStack {
                            Spacer()
                            Text(StringConstants.Common.error)
                                .padding(.leading, 20)
                                .font(.verlagBoldAdaptive(size: 30))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)

                            Spacer()
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showAlert = false
                                }
                            }) {
                                Image(StringConstants.DRTImages.crossImage)
                                    .resizable()
                                    .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                                    .background(Color.clear)
                                    .contentShape(Rectangle())
                            }.padding(.bottom, 10)
                        }

                        VStack {
                            Text(viewModel.errorMessage ?? "This")
                                .font(.verlagBookAdaptive(size: 18))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                        }.onChange(of: errorMessages) { _ in
                            print(errorMessages, "new")
                            
                        }
                    }
                    .padding(30)
                    .padding(.top, 30)
                    .background(Color.FFCE_62)
                    .frame(width: geometry.size.width * 1)
                    .position(x: geometry.size.width / 2, y: geometry.safeAreaInsets.top)
                    
                }
            }.padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? -90 : -60)

            .edgesIgnoringSafeArea(.all)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // Fetch products from Core Data for offline merchandise display
    private func fetchProducts(orderId: Int) {
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "order_id == %@", NSNumber(value: orderId))
        
        do {
            let fetchedProducts = try PersistenceController.shared.container.viewContext.fetch(fetchRequest)
            self.products = fetchedProducts
        } catch {
            print("Error fetching products: \(error)")
        }
    }
}
