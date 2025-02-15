//
//  EditOrderView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 15/02/25.
//


import SwiftUI

struct EditOrderView: View {
    var order: Order
    var onUpdate: ([String: Any]) -> Void

    @State private var buyerName: String
    @State private var cc: String
    @State private var phone: String
    @Environment(\.presentationMode) private var presentationMode

    init(order: Order, onUpdate: @escaping ([String: Any]) -> Void) {
        self.order = order
        self.onUpdate = onUpdate

        _buyerName = State(initialValue: order.buyer_name ?? "")
        _cc = State(initialValue: order.cc ?? "")
        _phone = State(initialValue: order.phone ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Order Details")) {
                    TextField("Buyer Name", text: $buyerName)
                    TextField("CC", text: $cc)
                    TextField("Phone", text: $phone)
                }
            }
            .navigationBarTitle("Edit Order", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    let updatedAttributes: [String: Any] = [
                        "oid": order.oid ?? NSNumber(value: 1),
                        "buyer_name": buyerName,
                        "cc": cc,
                        "phone": phone
                    ]
                    onUpdate(updatedAttributes)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
