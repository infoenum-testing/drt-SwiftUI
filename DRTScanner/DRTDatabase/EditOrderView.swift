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
                Section(header: Text(StringConstants.Common.editOrderDetails)) {
                    TextField(StringConstants.Common.buyerName, text: $buyerName)
                    TextField(StringConstants.Common.cc, text: $cc)
                    TextField(StringConstants.Common.phone, text: $phone)
                }
            }
            .navigationBarTitle(StringConstants.Common.editOrder, displayMode: .inline)
            .navigationBarItems(
                leading: Button(StringConstants.Common.cancel) {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(StringConstants.Common.save) {
                    let updatedAttributes: [String: Any] = [
                        StringConstants.Attributes.oid: order.oid ?? NSNumber(value: 1),
                        StringConstants.Attributes.buyerName: buyerName,
                        StringConstants.Attributes.cc: cc,
                        StringConstants.Attributes.phone: phone
                    ]
                    onUpdate(updatedAttributes)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
