//
//  MerchandiseOrderCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 07/03/25.
//

import SwiftUI
import CoreData
import IQAPIClient
import SDWebImageSwiftUI

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
    @ObservedObject var lookupByOrderResultViewModel:LookupByOrderResultViewModel
    @Binding var showAlert: Bool
    
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                VStack {
                    // Display SVG or image for merchandise icon
                    if merchandiseOrder.iconSrc.lowercased().hasSuffix(".svg") {
                        if let url = URL(string: merchandiseOrder.iconSrc) {
                            ZStack {
                                WebImage(url: url)
                                    .resizable()
                                    .onSuccess { _, _, _ in
                                        DispatchQueue.main.async {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                isLoadingSvgImage = false
                                            }
                                        }
                                    }
                                    .onFailure { error in
                                        print("⚠️ Logo load failed: \(error.localizedDescription)")
                                    }
                                    .onAppear {
                                        isLoadingSvgImage = true
                                    }
                                    .frame(width: 70.adaptiveForIpad, height: 70.adaptiveForIpad)
                                
                                if isLoadingSvgImage {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
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
                    CustomsText(title: "\(merchandiseOrder.qty)", textFont: .verlagBookAdaptive(size: 20), foregroundColour: .primaryText)
                        .frame(width: 30.adaptiveForIpad, height: 30.adaptiveForIpad)
                        .background(Color.secondaryBg)
                        .clipShape(Circle())
                        .padding(.top, -20)
                        .padding(.leading, 20)
                }
                
                HStack(alignment: .center, spacing: 5) {
                    // Display merchandise name and variant
                    CustomsText(title: merchandiseOrder.name, textFont: .verlagBoldAdaptive(size: 20), foregroundColour: .primaryBg)
                    CustomsText(title: merchandiseOrder.variantName, textFont: .verlagBookAdaptive(size: 15), foregroundColour: .neutralText)
                    Spacer()
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
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                            .frame(width: 50.adaptiveForIpad, height: 50.adaptiveForIpad)
                    } else if merchandiseOrder.qty == merchandiseOrder.qtyScanned {
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
            .onChange(of: merchandiseOrder.qtyScanned) { newValue in
                print("qtyScanned updated to \(newValue)")
                isScanned = merchandiseOrder.qty == newValue
            }
            Rectangle()
                .fill(Color.colorButtonText)
                .frame(width: UIScreen.main.bounds.width, height: 1)
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
                    isLoading = false
                    
                    switch result {
                    case .success(let jsonResponse):
                        let valid = jsonResponse.valid
                        let message = jsonResponse.message
                        let scannedAt = String(jsonResponse.tsScanned)
                        
                        if !valid {
                            lookupByOrderResultViewModel.errorMessage = message
                            showAlert = true
                            return
                        }
                        merchandiseOrder.objectWillChange.send()
                        if let qty = jsonResponse.qty {
                            merchandiseOrder.qty = qty
                        }
                        if let qtyScanned = jsonResponse.qtyScanned {
                            merchandiseOrder.qtyScanned = qtyScanned
                        }
                        merchandiseOrder.date_Scanned = scannedAt
                        isScanned = merchandiseOrder.qty ==  merchandiseOrder.qtyScanned
                        
                    case .failure(let error):
                        if NetworkMonitor.shared.isNetworkAvailable() {
                            lookupByOrderResultViewModel.errorMessage = error.localizedDescription
                        } else {
                            lookupByOrderResultViewModel.errorMessage = StringManager.shared.strings.noInternet.description
                        }
                        showAlert = true
                    }
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
            product.qtyScanned = Int64(order.qtyScanned + 1)
            product.locally_scanned += 1
            
            if product.qtyScanned > product.qty {
                product.qtyScanned = product.qty
            }
            
            //            if product.qtyScanned == product.qty {
            product.date_scanned = Date()
            //            }
            
            try context.save()
            
            merchandiseOrder.qty = Int(product.qty)
            merchandiseOrder.qtyScanned = Int(product.qtyScanned)
            if let dateScanned = product.date_scanned {
                merchandiseOrder.date_Scanned = MerchandiseOrder.dateFormatter.string(from: dateScanned)
            }
            isScanned = product.qty == product.qtyScanned
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
