//
//  GoOfflineView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//


import SwiftUI
import IQAPIClient

//struct GoOfflineView: View {
//    @State private var isOffline = DRTHTTPService.shared.offline()
//    @State private var progress: CGFloat = 0.0
//    @State private var showAlert = false
//    @State private var alertTitle = ""
//    @State private var alertMessage = ""
//    @State private var name = ""
//    @Binding var isPresented: Bool
//
//    var body: some View {
//            VStack(spacing: 5) {
//                HStack {
//                    Spacer()
//                    Text("Go offline")
//                        .font(Font.custom("Verlag-Bold", size: 30))
//                        .foregroundColor(.customWhite)
//                        .padding(.leading, 10)
//                    Spacer()
//                    Button(action: {
//                        withAnimation(.easeInOut(duration: 0.5)) {
//                            isPresented = false
//                        }
//                    }) {
//                        Image("Popup_cross_btn")
//                            .padding()
//                    }
//                }
//
//                Text("By going offline, the database will be downloaded to this device and nobody else will be able to scan tickets to this show until I go select to go back online. When I go back online, the tickets I scanned will be uploaded back to the server.\n\nBy signing my name, I understand and agree to the above:")
//                    .font(Font.custom("Avenir-Light", size: 18))
//                    .foregroundColor(.black)
//                    .multilineTextAlignment(.leading)
//
//                TextField("Type your name here", text: $name)
//                    .padding(5)
//                    .background(Color.customWhite) // Ensure background color is correct
//                    .foregroundColor(Color.gray)
//                    .frame(alignment: .center)
//
//                if isOffline {
//                    ProgressView(value: progress, total: 1.0)
//                }
//
//                HStack {
//                    Button(action: {
//                    }) {
//                        Text("Continue")
//                            .padding()
//                            .font(Font.custom("Verlag-Bold", size: 26))
//                            .foregroundColor(.showCodeText)
//                    }
//                    .disabled(name.isEmpty)
//
//                    Spacer()
//
//                    Button(action: {
//                        withAnimation(.easeInOut(duration: 0.5)) {
//                            isPresented = false
//                        }
//                    }) {
//                        Text("Cancel")
//                            .padding()
//                            .font(Font.custom("Verlag-Bold", size: 26))
//                            .foregroundColor(.showCodeText)
//                    }
//                }
//            }
//            .padding([.leading, .trailing], 10)
//            .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 2)
//            .background(Color.showCodeButton)
//    }
//
//    private func goOfflineButtonAction() {
//        let httpService = DRTHTTPService.shared
//
//        if isOffline {
//            alertTitle = "Going online"
//            alertMessage = "Prepare uploading"
//            showAlert = true
//
//            guard let user = DRTUser.getCurrentUser() else { return }
//
//            httpService.uploadOfflineData(showCode: user.showCode ?? "", showID: user.showId ?? "", uploadProgressBlock: { progress in
//                DispatchQueue.main.async {
//                    self.progress = progress
//                }
//            }, completionHandler: { success, message, error in
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                    if let error = error {
//                        alertTitle = "Upload failed!"
//                        alertMessage = error.localizedDescription
//                    } else if !success {
//                        alertTitle = "Upload failed!"
//                        alertMessage = message.isEmpty ? "The upload failed due to an unexpected error." : message
//                    } else {
//                        alertTitle = "Message"
//                        alertMessage = message
//                        httpService.trashAllOfflineScans()
//                        httpService.goOffline(false)
//                        isOffline = false
//                    }
//                    showAlert = true
//                }
//            })
//        } else {
//            alertTitle = StringConstants.Offline.title
//            alertMessage = StringConstants.Offline.description
//            showAlert = true
//        }
//    }
//}

struct GoOfflineView: View {
    @State private var progress: CGFloat = 0.0
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var name = ""
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Spacer()
                Text("Go offline")
                    .font(Font.custom("Verlag-Bold", size: 30))
                    .foregroundColor(.customWhite)
                    .padding(.leading, 10)
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isPresented = false
                    }
                }) {
                    Image("Popup_cross_btn")
                        .padding()
                }
            }
            
            Text("By going offline, the database will be downloaded to this device and nobody else will be able to scan tickets to this show until I go select to go back online. When I go back online, the tickets I scanned will be uploaded back to the server.\n\nBy signing my name, I understand and agree to the above:")
                .font(Font.custom("Avenir-Light", size: 18))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            TextField("Type your name here", text: $name)
                .padding(5)
                .background(Color.customWhite)
                .foregroundColor(Color.gray)
                .frame(alignment: .center)
            
            
            
            HStack {
                Button(action: fetchAndSaveOfflineData) {
                    Text("Continue")
                        .padding()
                        .font(Font.custom("Verlag-Bold", size: 26))
                        .foregroundColor(.showCodeText)
                }
                //                .disabled(name.isEmpty) // Disable if name is empty
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isPresented = false
                    }
                }) {
                    Text("Cancel")
                        .padding()
                        .font(Font.custom("Verlag-Bold", size: 26))
                        .foregroundColor(.showCodeText)
                }
            }
        }
        .padding([.leading, .trailing], 10)
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 2)
        .background(Color.showCodeButton)
    }
    
    private func fetchAndSaveOfflineData() {
        IQAPIClient.getAllDataOffline(code: "289-6385", username: name) { result in
            switch result {
            case .success(let orderDetailsModel):
                
                if let orderDetails = orderDetailsModel as? [String: Any],
                   let ordersArray = orderDetails["orders"] as? [[Any]] {
                    var orders: [Orders] = []
                    
                    for order in ordersArray {
                        if order.count >= 4,
                           let orderId = order[0] as? Int,
                           let buyerName = order[1] as? String,
                           let cc = order[2] as? String,
                           let phone = order[3] as? String {
                            let order = Orders(buyerName: buyerName, cc: cc, phone: phone, orderId: orderId, studioId: 0)
                            orders.append(order)
                        }
                    }
                    
                    let context = PersistenceController.shared.container.viewContext
                    context.perform {
                        DRTDatabaseManager.shared.saveOrders(from: orders, context: context)
                        
                        DispatchQueue.main.async {
                            showAlert(title: "Success", message: "Data downloaded & saved offline.")
                        }
                    }
                    
                } else {
                    DispatchQueue.main.async {
                        showAlert(title: "Error", message: "Failed to parse orders data.")
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    showAlert(title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    
    private func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}
