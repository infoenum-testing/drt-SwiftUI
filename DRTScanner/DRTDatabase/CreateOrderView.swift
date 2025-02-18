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
                Section(header: Text(StringConstants.Common.orderDetails)) {
                    TextField(StringConstants.Common.oID, text: $oid).keyboardType(.numberPad)
                    TextField(StringConstants.Common.buyerName, text: $buyerName)
                    TextField(StringConstants.Common.cc, text: $cc)
                    TextField(StringConstants.Common.phone, text: $phone).keyboardType(.phonePad)
                }
            }
            .navigationBarTitle(StringConstants.Common.createOrder, displayMode: .inline)
            .navigationBarItems(
                leading: Button(StringConstants.Common.cancel) {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(StringConstants.Common.save) {
                    guard let oidNumber = Int(oid) else { return }  // Ensure OID is valid

                    let orderAttributes: [String: Any] = [
                        StringConstants.Attributes.oid : NSNumber(value: oidNumber),
                        StringConstants.Attributes.buyerName : buyerName,
                        StringConstants.Attributes.cc : cc,
                        StringConstants.Attributes.phone : phone
                    ]
                    onCreate(orderAttributes)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
