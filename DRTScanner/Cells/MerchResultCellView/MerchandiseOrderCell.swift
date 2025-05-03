//
//  MerchandiseOrderCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 07/03/25.
//

import SwiftUI
import CoreData
import IQAPIClient

// MerchandiseOrderCell displays a merchandise order item with scan functionality and status
struct MerchandiseOrderCell: View {
    @ObservedObject var merchandiseOrder: MerchandiseOrder
    let context = PersistenceController.shared.container.viewContext
    @State private var isScanning = false
    @State private var scannedTime: String?
    @State private var scannedQty: Int?
    @State private var qtyScanned: Int?
    @State private var isScanned = false
    @AppStorage("isOfflineMode") private var isOffline: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    @State private var isLoading = false
    @State private var isLoadingSvgImage = false
    
    var body: some View {
        HStack(spacing: 15) {
            VStack {
                // Display SVG or image for merchandise icon
                if merchandiseOrder.iconSrc.lowercased().hasSuffix(".svg") {
                    if let url = URL(string: merchandiseOrder.iconSrc) {
                        ZStack {
                            SVGWebView(url: url, isLoading: $isLoadingSvgImage)
                                .frame(width: 70.adaptiveForIpad, height: 70.adaptiveForIpad)
                                .onAppear {
                                    isLoadingSvgImage = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        isLoadingSvgImage = false
                                    }
                                }
                            
                            if isLoadingSvgImage {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                    .frame(width: 50.adaptiveForIpad, height: 50.adaptiveForIpad)
                                    .transition(.opacity)
                            }
                        }
                    } else {
                        Color.clear.frame(width: 70, height: 70)
                    }
                } else {
                    AsyncImage(url: URL(string: merchandiseOrder.iconSrc)) { phase in
                        switch phase {
                        case .success(let image): image.resizable()
                        case .failure(_): Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                        default: ProgressView().frame(width: 70.adaptiveForIpad, height: 70.adaptiveForIpad)
                        }
                    }
                    .frame(width: 70.adaptiveForIpad, height: 70.adaptiveForIpad)
                }
                
                // Display quantity
                Text("\(merchandiseOrder.qty)")
                    .font(.verlagBookAdaptive(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 30.adaptiveForIpad, height: 30.adaptiveForIpad)
                    .background(merchandiseOrder.qty == merchandiseOrder.qtyScanned ? Color.FFCE_62 : Color.FFCE_62)
                    .clipShape(Circle())
                    .padding(.top, -20)
                    .padding(.leading, 20)
                
//                Text("Scanned: \(merchandiseOrder.qtyScanned)")
//                    .font(.verlagBookAdaptive(size: 15))
//                    .foregroundColor(.black)
            }
            
            HStack(alignment: .center, spacing: 5) {
                // Display merchandise name and variant
                Text(merchandiseOrder.name)
                    .font(.verlagBoldAdaptive(size: 20))
                    .foregroundColor(Color.customGreen)
                
                Text(merchandiseOrder.variantName)
                    .font(.verlagBookAdaptive(size: 15))
                    .foregroundColor(.black)
                Spacer()
                
//                if isScanned || !merchandiseOrder.date_Scanned.isEmpty {
//                    Text("Scanned at \(scannedTime ?? merchandiseOrder.date_Scanned)")
//                        .font(.verlagBoldAdaptive(size: 18))
//                        .foregroundColor(.green)
//                        .padding(.top, 10)
//                } else {
//                    Text("Not yet scanned")
//                        .font(.verlagBoldAdaptive(size: 18))
//                        .foregroundColor(Color.customGreen)
//                        .padding(.top, 10)
//                }
            }
            
            Spacer()
            
            // Scan button and status
            Button(action: {
                if merchandiseOrder.qty != merchandiseOrder.qtyScanned {
                    withAnimation {
                        updateMerchWithScannedQrCode()
                    }
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .frame(width: 50.adaptiveForIpad, height: 50.adaptiveForIpad)
                }
                else if merchandiseOrder.qty == merchandiseOrder.qtyScanned {
                    Image(StringConstants.DRTImages.greenCheckImage)
                        .resizable()
                        .frame(width: 50.adaptiveForIpad, height: 50.adaptiveForIpad)
                        .transition(.scale)
                } else {
                    Image(StringConstants.DRTImages.scanNow)
                        .resizable()
                        .frame(width: 50.adaptiveForIpad, height: 50.adaptiveForIpad)
                }
            }
            .padding(.trailing, 10)
        }
        .frame(height: 130.adaptiveForIpad)
        .onAppear {
            loadScannedTime()
            isScanned = merchandiseOrder.qty == merchandiseOrder.qtyScanned
        }
    }
    
    // Handles scanning logic, updates state and calls API if online
    private func updateMerchWithScannedQrCode() {
        guard merchandiseOrder.qty > 0 else { return }
        isLoading = true
        
        if isOffline {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                processScanResult(success: true, dateScanned: nil)
                isLoading = false
            }
        } else {
            guard let qrCode = merchandiseOrder.qrCode else {
                print("QR code is nil")
                isLoading = false
                return
            }

            IQAPIClient.scanProductQrCode(code: savedShowCode ?? "", qr: qrCode) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let jsonResponse):
                        let valid = jsonResponse["valid"] as? Bool ?? false
                        let message = jsonResponse["message"] as? String ?? "Unknown error"
                        let scannedAt = jsonResponse["date_scanned"] as? String
                        let qty = jsonResponse["qty"] as? Int ?? merchandiseOrder.qty
                        let qtyScanned = jsonResponse["qty_scanned"] as? Int ?? merchandiseOrder.qtyScanned
                        
                        if valid || message.contains("Previously scanned") {
                            processScanResult(success: true, dateScanned: scannedAt)
                        } else {
                            print("Scan failed: \(message)")
                        }
                    case .failure(let error):
                        print("Error scanning merchandise: \(error.localizedDescription)")
                    }
                    isLoading = false
                }
            }
        }
    }
    
    // Processes the result of a scan, updates scanned time and status
    private func processScanResult(success: Bool, dateScanned: String?) {
        guard success else { return }
        
        if let scannedAt = dateScanned {
            scannedTime = scannedAt
            merchandiseOrder.date_Scanned = scannedAt
        } else {
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy, HH:mm"
            scannedTime = formatter.string(from: currentDate)
            merchandiseOrder.date_Scanned = scannedTime ?? ""
        }
        
        if merchandiseOrder.qty != merchandiseOrder.qtyScanned {
//            merchandiseOrder.qtyScanned += 1
        }
        
        isScanned = merchandiseOrder.qty == merchandiseOrder.qtyScanned
        
        saveScannedStatus(for: merchandiseOrder)
    }
    
    // Loads the scanned time from the order
    private func loadScannedTime() {
        scannedTime = merchandiseOrder.date_Scanned
    }
    
    // Saves the scanned status to Core Data for the given order
    private func saveScannedStatus(for order: MerchandiseOrder) {
        guard let qrCode = order.qrCode?.first, !qrCode.isEmpty else {
            print("QR Code is nil or empty.")
            return
        }
        
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "qrCode == %@", qrCode)
        
        do {
            let products = try context.fetch(fetchRequest)
            let product: Product
            
            if let existingProduct = products.first {
                product = existingProduct
            } else {
                product = Product(context: context)
                product.qrCode = qrCode
            }
            
            product.qty = Int64(order.qty)
            product.qty_scanned = Int64(order.qtyScanned + 1)
            
            if product.qty_scanned > product.qty {
                product.qty_scanned = product.qty
            }
            
            if product.qty_scanned == product.qty {
                product.date_scanned = Date()
            }
            
            try context.save()
            
            merchandiseOrder.qty = Int(product.qty)
            merchandiseOrder.qtyScanned = Int(product.qty_scanned)
            if let dateScanned = product.date_scanned {
                merchandiseOrder.date_Scanned = MerchandiseOrder.dateFormatter.string(from: dateScanned)
            }
            
            isScanned = product.qty == product.qty_scanned
            
        } catch {
            print("Failed to save scanned status: \(error)")
        }
    }
}

// Loads the first Product from Core Data
func loadProductFromCoreData(context: NSManagedObjectContext) -> Product? {
    let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
    do {
        let products = try context.fetch(fetchRequest)
        return products.first
    } catch {
        print("Failed to fetch product: \(error)")
        return nil
    }
}
