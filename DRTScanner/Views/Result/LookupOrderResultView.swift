//
//  LookupOrderResultView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//

//import SwiftUI
//
//struct LookupOrderResultView: View {
//    let inputText: String
//    var dismissAction: () -> Void
//    @StateObject private var viewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
//    @State private var orders: [Orders] = []
//    @State private var seats: [SeatModel] = []
//    @AppStorage("showCode") private var savedShowCode: String?
//    @AppStorage("merchandise") private var isMerchandise: Bool = true
//    
//    let errorMessage: String?
//    let order: Orders?
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
//                        
//                        Spacer()
//                    }
//                }.padding()
//                .background(Color.showCodeButton)
//                .frame(maxWidth: .infinity)
//            } else {
//                VStack {
//                    HStack (alignment: .center){
//                        Button(action: {
//                            withAnimation(.easeInOut(duration: 0.3)) {
//                                dismissAction()
//                            }
//                        }) {
//                            Image("left_side_arrow")
//                        }.padding(.leading, 20)
//                        
//                        Spacer()
//                        Text(order?.buyerName?.uppercased() ?? StringConstants.Common.noOrderFound)
//                            .foregroundColor(Color.customWhite)
//                            .font(Font.custom("Verlag-Black", size: 25))
//                            .padding(.trailing, 20)
//                        Spacer()
//                    }
//                    HStack(alignment: .center) {
//                        Text("\(StringConstants.Common.Order) \(order?.orderId ?? 0)")
//                            .font(Font.custom("Verlag-Bold", size: 15))
//                            .foregroundColor(Color.customWhite)
//                        Text("CC \(order?.cc ?? "")")
//                            .font(Font.custom("Verlag-Bold", size: 15))
//                            .foregroundColor(Color.customWhite)
//                    }
//                }.padding([.bottom, .top])
//                .background(Color.showCodeButton)
//                .frame(maxWidth: .infinity)
//
//                VStack {
//                    if isMerchandise {
//                        if let order = loadMerchandiseOrder(from: sampleJSON), isMerchandise {
//                            MerchandiseOrderCell(merchandiseOrder: order)
//                        }
//                    } else {
//                        List {
//                            ForEach(seats.indices, id: \.self) { index in
//                                SeatCell(seat: $seats[index])
//                            }
//                        }.listStyle(.plain)
//                            .padding(0)
//                    }
//                }
//            }
//        }
//            .background(Color.customWhite)
//        .task {
//            await viewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
//            self.orders = viewModel.orders
//            if let seats = viewModel.seatsModel {
//                self.seats = seats
//            }
//        }
//    }
//}

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
   
    
    let errorMessage: String?
    let order: OrdersNewApi?

    @State private var products: [Product] = []

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
                }.padding()
                .background(Color.FFCE_62)
                .frame(maxWidth: .infinity)
            } else {
                VStack {
                    HStack (alignment: .center){
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dismissAction()
                            }
                        }) {
                            Image("left_side_arrow")
                        }.padding(.leading, 20)
                        
                        Spacer()
                        Text(order?.buyerName?.uppercased() ?? StringConstants.Common.noOrderFound)
                            .foregroundColor(Color.customWhite)
                            .font(Font.custom("Verlag-Black", size: 25))
                            .padding(.trailing, 20)
                        Spacer()
                    }
                    HStack(alignment: .center) {
                        Text("\(StringConstants.Common.Order) \(order?.orderId ?? 0)")
                            .font(Font.custom("Verlag-Bold", size: 15))
                            .foregroundColor(Color.customWhite)
                        Text("CC \(order?.cc ?? "")")
                            .font(Font.custom("Verlag-Bold", size: 15))
                            .foregroundColor(Color.customWhite)
                    }
                }.padding([.bottom, .top])
                    .background(Color.FFCE_62)
                .frame(maxWidth: .infinity)

                VStack {
                    if isMerchandise ?? false {
                       if isOfflineMode {
                            if !products.isEmpty {
                                ForEach(products, id: \.self) { product in
                                    let merchandiseOrder = MerchandiseOrder(from: product)
                                    MerchandiseOrderCell(merchandiseOrder: .constant(merchandiseOrder))
                                }
                                Spacer()
                            } else {
                                Text("No merchandise found.")
                                    .foregroundColor(Color.gray)
                                Spacer()
                            }
                       } else {
                           List {
                               ForEach(merch.indices, id: \.self) { index in
                                   MerchandiseOrderCell(merchandiseOrder: .constant(MerchandiseOrder(from: merch[index])))
                               }
                           }.listStyle(.plain)
                               .padding(0)
                       }
                    } else {
                        List {
                            ForEach(seats.indices, id: \.self) { index in
                                SeatCell(seat: $seats[index])
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
            await viewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
            self.seats = viewModel.seatsModel ?? []
            self.merch = viewModel.merchModel ?? []
            if let orderId = order?.orderId {
                fetchProducts(orderId: orderId)
            }
        }
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

extension MerchandiseOrder {

    init(from product: Product) {
        self.orderId = Int(product.order_id)
        self.name = product.name ?? ""
        self.variantName = product.variantName ?? ""
        
        if let qrCode = product.qrCode, !qrCode.isEmpty {
            self.qrCode = [qrCode]
        } else {
            self.qrCode = []
        }
        
        self.qty = Int(product.qty)
        self.qtyScanned = Int(product.qty_scanned)
        self.iconSrc = product.icon_src ?? ""
        self.date_Scanned = product.date_scanned?.formatted() ?? ""
    }
}

extension MerchandiseOrder {
    init(from merchandise: Merchandise) {
        self.orderId = 3333876
        self.name = merchandise.name ?? ""
        self.variantName = merchandise.variantName ?? ""
        
        if let qrMerch = merchandise.qr, !qrMerch.merch.isEmpty {
            self.qrCode = qrMerch.merch
        } else {
            self.qrCode = []
        }
        
        self.qty = merchandise.qty ?? 0
        self.qtyScanned = merchandise.qty ?? 0
        self.iconSrc = merchandise.icon ?? ""
        self.date_Scanned = merchandise.scannedTime?.formatted() ?? ""
    }
}
