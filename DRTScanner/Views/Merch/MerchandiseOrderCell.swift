//
//  MerchandiseOrderCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 07/03/25.
//

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
    @AppStorage("showCode") private var savedShowCode: String?
    @State private var isLoading = false
    @State private var isLoadingSvgImage = false
    
    var body: some View {
        HStack(spacing: 15) {
            VStack {
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
                
                Text("\(merchandiseOrder.qty)")
                    .font(.verlagBookAdaptive(size: 20))
                    .foregroundColor(.white)
                    .frame(width: 40.adaptiveForIpad, height: 40.adaptiveForIpad)
                    .background(merchandiseOrder.qty == merchandiseOrder.qtyScanned ? Color.green : Color.orange)
                    .clipShape(Circle())
                    .padding(.top, -30)
                    .padding(.leading, -10)
                
                Text("Scanned: \(merchandiseOrder.qtyScanned)")
                    .font(.verlagBookAdaptive(size: 15))
                    .foregroundColor(.black)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(merchandiseOrder.name)
                    .font(.verlagBoldAdaptive(size: 20))
                    .foregroundColor(Color.customGreen)
                
                Text(merchandiseOrder.variantName)
                    .font(.verlagBookAdaptive(size: 15))
                    .foregroundColor(.black)
                
                if isScanned {
                    Text("Scanned at \(scannedTime ?? merchandiseOrder.date_Scanned)")
                        .font(.verlagBoldAdaptive(size: 18))
                        .foregroundColor(.green)
                        .padding(.top, 10)
                } else {
                    Text("Not yet scanned")
                        .font(.verlagBoldAdaptive(size: 18))
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
struct SVGWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = context.coordinator
        return webView
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Load SVG content directly
        fetchSVGContent(from: url) { svgContent in
            DispatchQueue.main.async {
                let svgHTML = """
        <html>
        <head>
          <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1.0"/>
          <style>
            body { margin: 0; padding: 0; display: flex; align-items: center; justify-content: center; background-color: transparent; }
            svg { width: 100%; height: 100%; }
          </style>
        </head>
        <body>
          \(svgContent) <!-- Directly insert SVG data -->
        </body>
        </html>
        """
                uiView.loadHTMLString(svgHTML, baseURL: nil)
            }
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: SVGWebView
        init(_ parent: SVGWebView) {
            self.parent = parent
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
            }
        }
    }
    /// Fetch SVG raw content as a string
    func fetchSVGContent(from url: URL, completion: @escaping (String) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let svgString = String(data: data, encoding: .utf8) {
                completion(svgString)
            } else {
                completion("") // Fallback if fetch fails
            }
        }.resume()
    }
}
