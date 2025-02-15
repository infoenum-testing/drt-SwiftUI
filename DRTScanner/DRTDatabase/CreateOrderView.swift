//
//  CreateOrderView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 15/02/25.
//


import SwiftUI

struct CreateOrderView: View {
    var onCreate: ([String: Any]) -> Void
    
    @State private var oid: String = ""
    @State private var buyerName: String = ""
    @State private var cc: String = ""
    @State private var phone: String = ""
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Order Details")) {
                    TextField("OID", text: $oid)
                        .keyboardType(.numberPad)
                    TextField("Buyer Name", text: $buyerName)
                    TextField("CC", text: $cc)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
            }
            .navigationBarTitle("Create Order", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    guard let oidNumber = Int(oid) else { return }  // Ensure OID is valid

                    let orderAttributes: [String: Any] = [
                        "oid": NSNumber(value: oidNumber),
                        "buyer_name": buyerName,
                        "cc": cc,
                        "phone": phone
                    ]
                    onCreate(orderAttributes)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
