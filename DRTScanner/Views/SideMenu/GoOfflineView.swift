//
//  GoOfflineView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//

import SwiftUI
import IQAPIClient

struct GoOfflineView: View {
    @State private var progress: CGFloat = 0.0
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var name = ""
    @State private var isSyncing = false
    @Binding var isPresented: Bool
    
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    
    var isContinueDisabled: Bool {
        name.count < 5 || isSyncing
    }
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Spacer()
                Text("Go offline")
                    .font(Font.custom("Verlag-Bold", size: 30))
                    .foregroundColor(.customWhite)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image("Popup_cross_btn").padding()
                }
                .disabled(isSyncing)
            }
            
            Text("By going offline, the database will be downloaded to this device, and nobody else will be able to scan tickets for this show until I go back online. When I return online, the scanned tickets will be uploaded back to the server.\n\nBy signing my name, I understand and agree to the above:")
                .font(Font.custom("Avenir-Light", size: 18))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            TextField("Type your name here", text: $name)
                .padding(5)
                .background(Color.customWhite)
                .foregroundColor(Color.gray)
                .frame(alignment: .center)
                .disabled(isSyncing)
            
            if isSyncing {
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle())
                    .background(.customWhite)
                    .foregroundColor(.customWhite)
                    .padding()
                    .animation(.easeInOut, value: progress)
            }
            
            HStack {
                Button(action: goOffline) {
                    Text("Continue")
                        .padding()
                        .font(Font.custom("Verlag-Bold", size: 26))
                        .foregroundColor(isContinueDisabled ? .gray : .showCodeText)
                }
                .disabled(isContinueDisabled)
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Text("Cancel")
                        .padding()
                        .font(Font.custom("Verlag-Bold", size: 26))
                        .foregroundColor(.showCodeText)
                }
                .disabled(isSyncing)
            }
        }
        .padding([.leading, .trailing], 10)
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 2)
        .background(Color.showCodeButton)
    }
    
    private func goOffline() {
        guard name.count >= 5 else { return }
        
        isSyncing = true
        progress = 0.0
        
        IQAPIClient.getAllDataOffline(code: "289-6385", username: name) { result in
            switch result {
            case .success(let orderDetailsModel):
                if let orderDetails = orderDetailsModel as? [String: Any] {
                    DispatchQueue.global(qos: .userInitiated).async {
                        DRTDatabaseManager.shared.syncServerData(
                            serverDict: orderDetails,
                            progressBlock: { syncProgress in
                                DispatchQueue.main.async {
                                    self.progress = CGFloat(syncProgress)
                                }
                            },
                            completionBlock: { success, error in
                                DispatchQueue.main.async {
                                    isSyncing = false
                                    if success {
                                        isOfflineMode = true
                                        isPresented = false
                                    } else {
                                       
                                    }
                                }
                            }
                        )
                    }
                } else {
                    DispatchQueue.main.async {
                        isSyncing = false
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    isSyncing = false
                }
            }
        }
    }
}
