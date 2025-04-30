//
//  LookupOrderResultView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//

import SwiftUI
import CoreData

struct LookupOrderResultView: View {
    let inputText: String
    var dismissAction: () -> Void
    @StateObject private var viewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @State private var seats: [SeatModel] = []
    @State private var merch: [Merchandise] = []
    @AppStorage("showCode") private var savedShowCode: String?
    @AppStorage("isMerchandise") private var isMerchandise: Bool?
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @State private var isLoadingMerch = true
    @State private var showAlert = false
    @State  var errorMessages: String? = nil
    let errorMessage: String?
    var order: OrdersNewApi?
    
    @State private var products: [Product] = []
    
    var body: some View {
        VStack {
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
                            Text("Error")
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
                            }
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
            }.padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? -90 : -30)

            .edgesIgnoringSafeArea(.all)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
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

//extension MerchandiseOrder {
//    
//    init(from product: Product) {
//        self.orderId = Int(product.order_id)
//        self.name = product.name ?? ""
//        self.variantName = product.variantName ?? ""
//        
//        if let qrCode = product.qrCode, !qrCode.isEmpty {
//            self.qrCode = [qrCode]
//        } else {
//            self.qrCode = []
//        }
//        
//        self.qty = Int(product.qty)
//        self.qtyScanned = Int(product.qty_scanned)
//        self.iconSrc = product.icon_src ?? ""
//        self.date_Scanned = product.date_scanned?.formatted() ?? ""
//    }
//}
//
//extension MerchandiseOrder {
//    init(from merchandise: Merchandise) {
//        self.orderId = 3333876
//        self.name = merchandise.name ?? ""
//        self.variantName = merchandise.variantName ?? ""
//        
//        if let qrMerch = merchandise.qr, !qrMerch.merch.isEmpty {
//            self.qrCode = qrMerch.merch
//        } else {
//            self.qrCode = []
//        }
//        
//        self.qty = merchandise.qty ?? 0
//        self.qtyScanned = merchandise.qty ?? 0
//        self.iconSrc = merchandise.icon ?? ""
//        self.date_Scanned = merchandise.scannedTime?.formatted() ?? ""
//    }
//}
//
