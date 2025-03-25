//
//  MerchandiseOrderCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 07/03/25.
//

import SwiftUI
import CoreData
import IQAPIClient

//struct MerchandiseOrderCell: View {
//    @Binding var merchandiseOrder: MerchandiseOrder
//    let context = PersistenceController.shared.container.viewContext
//    @State private var isScanning = false
//    @State private var scannedTime: String?
//    @State private var isScanned = false
//    @AppStorage("isOfflineMode") private var isOffline: Bool = false
//    @State private var isLoading = false
//    
//    var body: some View {
//        HStack(spacing: 15) {
//            VStack {
//                AsyncImage(url: URL(string: merchandiseOrder.iconSrc)) { phase in
//                    switch phase {
//                    case .success(let image):
//                        image
//                    case .failure(_):
//                        Image(systemName: "exclamationmark.triangle.fill")
//                            .foregroundColor(.red)
//                    case .empty:
//                        ProgressView()
//                            .frame(width: 70, height: 70)
//                    @unknown default:
//                        ProgressView()
//                            .frame(width: 70, height: 70)
//                    }
//                }
//                .frame(width: 70, height: 70)
//                
//                Text("\(merchandiseOrder.qty)")
//                    .font(.custom("Verlag-Book", size: 20))
//                    .foregroundColor(.white)
//                    .frame(width: 40, height: 40)
//                    .background(Color.orange)
//                    .clipShape(Circle())
//                    .padding(.top, -30)
//                    .padding(.leading, -10)
//            }
//            
//            VStack(alignment: .leading, spacing: 5) {
//                Text(merchandiseOrder.name)
//                    .font(.custom("Verlag-Bold", size: 20))
//                    .foregroundColor(Color.customGreen)
//                
//                Text(merchandiseOrder.variantName)
//                    .font(.custom("Verlag-Book", size: 15))
//                    .foregroundColor(.black)
//                
//                if isScanned {
//                    Text("Scanned at \(scannedTime ?? merchandiseOrder.date_Scanned)")
//                        .font(.custom("Verlag-Bold", size: 18))
//                        .foregroundColor(.green)
//                        .padding(.top, 10)
//                } else {
//                    Text("Not yet scanned")
//                        .font(.custom("Verlag-Bold", size: 18))
//                        .foregroundColor(Color.customGreen)
//                        .padding(.top, 10)
//                }
//            }
//            
//            Spacer()
//            
//            Button(action: {
//                withAnimation {
//                    updateMerchWithScannedQrCode()
//                }
//            }) {
//                if isScanning {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
//                        .frame(width: 50, height: 50)
//                }
//                else if isScanned || !merchandiseOrder.date_Scanned.isEmpty {
//                    Image("Green_circle_check_btn")
//                        .resizable()
//                        .frame(width: 50, height: 50)
//                        .transition(.scale)
//                } else {
//                    Image("scan_now")
//                        .resizable()
//                        .frame(width: 50, height: 50)
//                }
//            }
//            .padding(.trailing, 10)
//        }
//        .frame(height: 133)
//        .onAppear {
//            loadScannedTime()
//            isScanned = !merchandiseOrder.date_Scanned.isEmpty
//        }
//    }
//    
//    private func updateMerchWithScannedQrCode() {
//        guard !isScanned else { return }
//        isLoading = true
//        
//        if isOffline {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                let currentDate = Date()
//                let formatter = DateFormatter()
//                formatter.dateFormat = "HH:mm"
//                scannedTime = formatter.string(from: currentDate)
//                
//                merchandiseOrder.date_Scanned = scannedTime ?? ""
//                isScanned = true
//                isLoading = false
//                saveScannedStatus(for: merchandiseOrder)
//                
//            }
//        } else {
//            guard let qrCode = merchandiseOrder.qrCode else {
//                print("QR code is nil")
//                isLoading = false
//                return
//            }
//            
//            IQAPIClient.scanProductQrCode(code: "36060-5E56", qr: qrCode) { result in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .success(let jsonResponse):
//                        if let valid = jsonResponse["valid"] as? Bool, !valid {
//                            let message = jsonResponse["message"] as? String ?? "Unknown error"
//                            print("Scan failed: \(message)")
//                            
//                            if message.contains("Previously scanned") {
//                                isScanned = true
//                            }
//                        } else {
//                            let currentDate = Date()
//                            let formatter = DateFormatter()
//                            formatter.dateFormat = "HH:mm"
//                            scannedTime = formatter.string(from: currentDate)
//                            
//                            merchandiseOrder.date_Scanned = scannedTime ?? ""
//                            isScanned = true
//                        }
//                        
//                    case .failure(let error):
//                        print("Error scanning merchandise: \(error.localizedDescription)")
//                    }
//                    isLoading = false
//                }
//            }
//        }
//    }
//    
//    private func loadScannedTime() {
//        scannedTime = merchandiseOrder.date_Scanned
//    }
//    
//    private func saveScannedStatus(for order: MerchandiseOrder) {
//        guard let qrCode = order.qrCode, !qrCode.isEmpty else {
//            print("qrCode is nil or empty.")
//            return
//        }
//        
//        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "qrCode IN %@", qrCode)
//        
//        do {
//            if let product = try context.fetch(fetchRequest).first {
//                if order.date_Scanned.isEmpty {
//                    let currentDate = Date()
//                    product.date_scanned = currentDate
//                    print("Scanned status saved for \(order.name) with current date: \(currentDate)")
//                } else {
//                    let formatter = DateFormatter()
//                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//                    
//                    if let scannedDate = formatter.date(from: order.date_Scanned) {
//                        product.date_scanned = scannedDate
//                        print("Scanned status saved for \(order.name) with date: \(scannedDate)")
//                    } else {
//                        print("Failed to convert date string to Date. Expected format: yyyy-MM-dd HH:mm:ss")
//                    }
//                }
//                
//                try context.save()
//            }
//        } catch {
//            print("Failed to save scanned status: \(error)")
//        }
//    }
//    
//}
//
//
//struct MerchandiseOrderCell_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = PersistenceController.shared.container.viewContext
//        if let product = loadProductFromCoreData(context: context) {
//            let merchandiseOrder = MerchandiseOrder(from: product)
//            MerchandiseOrderCell(merchandiseOrder: .constant(merchandiseOrder))
//                .previewLayout(.fixed(width: 439, height: 133))
//        } else {
//            Text("Failed to load Core Data Product")
//                .foregroundColor(.red)
//        }
//    }
//}
//
//func loadProductFromCoreData(context: NSManagedObjectContext) -> Product? {
//    let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
//    do {
//        let products = try context.fetch(fetchRequest)
//        return products.first
//    } catch {
//        print("Failed to fetch product: \(error)")
//        return nil
//    }
//}

import SwiftUI
import CoreData
import IQAPIClient

struct MerchandiseOrderCell: View {
    @Binding var merchandiseOrder: MerchandiseOrder
    let context = PersistenceController.shared.container.viewContext
    @State private var isScanning = false
    @State private var scannedTime: String?
    @State private var isScanned = false
    @AppStorage("isOfflineMode") private var isOffline: Bool = false
    @State private var isLoading = false

    var body: some View {
        HStack(spacing: 15) {
            VStack {
                if merchandiseOrder.iconSrc.lowercased().hasSuffix(".svg") {
                    SVGImageView(url: URL(string: merchandiseOrder.iconSrc)!)
                        .frame(width: 70, height: 70)
                } else {
                    AsyncImage(url: URL(string: merchandiseOrder.iconSrc)) { phase in
                        switch phase {
                        case .success(let image): image.resizable()
                        case .failure(_): Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                        default: ProgressView().frame(width: 70, height: 70)
                        }
                    }
                    .frame(width: 70, height: 70)
                }
                
                Text("\(merchandiseOrder.qty)")
                    .font(.custom("Verlag-Book", size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(merchandiseOrder.qty == merchandiseOrder.qtyScanned ? Color.green : Color.orange)
                    .clipShape(Circle())
                    .padding(.top, -30)
                    .padding(.leading, -10)
                
                Text("Scanned: \(merchandiseOrder.qtyScanned)")
                    .font(.custom("Verlag-Book", size: 15))
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(merchandiseOrder.name)
                    .font(.custom("Verlag-Bold", size: 20))
                    .foregroundColor(Color.customGreen)
                
                Text(merchandiseOrder.variantName)
                    .font(.custom("Verlag-Book", size: 15))
                    .foregroundColor(.black)
                
                if isScanned {
                    Text("Scanned at \(scannedTime ?? merchandiseOrder.date_Scanned)")
                        .font(.custom("Verlag-Bold", size: 18))
                        .foregroundColor(.green)
                        .padding(.top, 10)
                } else {
                    Text("Not yet scanned")
                        .font(.custom("Verlag-Bold", size: 18))
                        .foregroundColor(Color.customGreen)
                        .padding(.top, 10)
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    updateMerchWithScannedQrCode()
                }
            }) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .frame(width: 50, height: 50)
                }
                else if merchandiseOrder.qty == merchandiseOrder.qtyScanned {
                    Image("Green_circle_check_btn")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .transition(.scale)
                } else {
                    Image("scan_now")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
            }
            .padding(.trailing, 10)
        }
        .frame(height: 133)
        .onAppear {
            loadScannedTime()
            isScanned = merchandiseOrder.qty == merchandiseOrder.qtyScanned
        }
    }
    
    private func updateMerchWithScannedQrCode() {
        guard merchandiseOrder.qty > 0 else { return }
        isLoading = true
        
        if isOffline {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                processScanResult(success: true, dateScanned: nil)
            }
        } else {
            guard let qrCode = merchandiseOrder.qrCode else {
                print("QR code is nil")
                isLoading = false
                return
            }
            
            IQAPIClient.scanProductQrCode(code: "36060-5E56", qr: qrCode) { result in
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
    
    private func processScanResult(success: Bool, dateScanned: String?) {
        guard success else { return }
        
        if let scannedAt = dateScanned {
            scannedTime = scannedAt
            merchandiseOrder.date_Scanned = scannedAt
        } else {
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            scannedTime = formatter.string(from: currentDate)
            merchandiseOrder.date_Scanned = scannedTime ?? ""
        }
        
        if merchandiseOrder.qty > 0 {
            merchandiseOrder.qty -= 1
            merchandiseOrder.qtyScanned += 1
        }
        
        isScanned = merchandiseOrder.qty == merchandiseOrder.qtyScanned
        
        saveScannedStatus(for: merchandiseOrder)
    }
    
    private func loadScannedTime() {
        scannedTime = merchandiseOrder.date_Scanned
    }
    
    private func saveScannedStatus(for order: MerchandiseOrder) {
        guard let qrCode = order.qrCode, !qrCode.isEmpty else {
            print("QR Code is nil or empty.")
            return
        }
        
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "qrCode == %@", qrCode)
        
        do {
            if let product = try context.fetch(fetchRequest).first {
                product.qty_scanned = Int64(order.qtyScanned)
                product.qty = Int64(order.qty)
                
                if product.qty > 0 {
                    product.qty -= 1
                    product.qty_scanned += 1
                }
                
                if product.qty == 0 {
                    let currentDate = Date()
                    product.date_scanned = currentDate
                }
                
                try context.save()
                
                merchandiseOrder.qtyScanned = Int(product.qty_scanned)
                merchandiseOrder.qty = Int(product.qty)
                merchandiseOrder.date_Scanned = product.date_scanned != nil ? MerchandiseOrder.dateFormatter.string(from: product.date_scanned!) : ""
                
                isScanned = product.qty == product.qty_scanned
            }
        } catch {
            print("Failed to save scanned status: \(error)")
        }
    }
}



struct MerchandiseOrderCell_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        if let product = loadProductFromCoreData(context: context) {
            let merchandiseOrder = MerchandiseOrder(from: product)
            MerchandiseOrderCell(merchandiseOrder: .constant(merchandiseOrder))
                .previewLayout(.fixed(width: 439, height: 133))
        } else {
            Text("Failed to load Core Data Product")
                .foregroundColor(.red)
        }
    }
}

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

import SwiftUI
import WebKit

struct SVGImageView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
