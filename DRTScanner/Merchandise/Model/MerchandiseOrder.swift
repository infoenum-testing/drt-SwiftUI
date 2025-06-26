//
//  MerchandiseOrder.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 07/03/25.
//

import SwiftUI

class MerchandiseOrder: ObservableObject, Identifiable {
    let id = UUID()
    
    @Published var orderId: Int?
    @Published var name: String
    @Published var variantName: String
    @Published var qrCode: [String]?
    @Published var qty: Int
    @Published var qtyScanned: Int
    @Published var iconSrc: String
    @Published var date_Scanned: String
    
    init(orderId: Int?, name: String, variantName: String, qrCode: [String]?, qty: Int, qtyScanned: Int, iconSrc: String, date_Scanned: String) {
        self.orderId = orderId
        self.name = name
        self.variantName = variantName
        self.qrCode = qrCode
        self.qty = qty
        self.qtyScanned = qtyScanned
        self.iconSrc = iconSrc
        self.date_Scanned = date_Scanned
    }
    
    convenience init(from product: Product) {
        self.init(
            orderId: Int(product.orderId),
            name: product.name ?? "",
            variantName: product.variantName ?? "",
            qrCode: product.qrCode?.isEmpty == false ? [product.qrCode!] : [],
            qty: Int(product.qty),
            qtyScanned: Int(product.qtyScanned),
            iconSrc: product.iconSrc ?? "",
            date_Scanned: product.date_scanned?.formatted() ?? ""
        )
    }
    
    convenience init(from merchandise: Merchandise) {
        self.init(
            orderId: merchandise.orderId,
            name: merchandise.name ?? "",
            variantName: merchandise.variantName ?? "",
            qrCode: merchandise.qr?.merch ?? [],
            qty: merchandise.qty ?? 0,
            qtyScanned: merchandise.qtyScanned ?? 0,
            iconSrc: merchandise.icon ?? "",
            date_Scanned: merchandise.scannedTime?.formatted() ?? ""
        )
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "@HH:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}
