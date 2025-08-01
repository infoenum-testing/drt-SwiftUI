//
//  GoOfflineView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//

import SwiftUI
import IQAPIClient
import Combine

struct GoOfflineView: View {
    @State private var progress: CGFloat = 0.0
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var name = ""
    @State private var isSyncing = false
    @State private var downloadLabel: String = ""
    
    @Binding var isPresented: Bool
    @Binding var showOfflineAlert: Bool
    @Binding var showOfflineSuccessAlert: Bool
    
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    @AppStorage("deviceScanCount") private var deviceScanCount: Int = 0
    
    @FocusState private var isNameFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    
    @ObservedObject var viewModel: LookupByOrderResultViewModel
    @EnvironmentObject var stringManager: StringManager
    
    var isContinueDisabled: Bool {
        name.count < 5 || isSyncing || !isValidName(name)
    }
    
    var body: some View {
        ZStack {
            AppBackGroundView(width: UIScreen.main.bounds.width,height:UIScreen.main.bounds.height * 0.6,shadow: true)
            VStack(alignment: .leading, spacing: 10) {
                Spacer()
                Text(stringManager.strings?.dialogGoOffline.description ?? StringConstants.SideMenuView.goOfflineViewDiscription)
                    .font(.verlagBookAdaptive(size: 18))
                    .foregroundColor(Color.primaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
                
                if !isSyncing {
                    TextField(stringManager.strings?.dialogGoOffline.typeName ?? StringConstants.SideMenuView.goOfflineViewTextFieldText, text: $name)
                        .padding(UIDevice.current.userInterfaceIdiom == .pad ? 20 : 15)
                        .font(.verlagBookAdaptive(size: 30))
                        .background(Color.neutralBg)
                        .foregroundColor(Color.neutralText)
                        .frame(alignment: .center)
                        .multilineTextAlignment(.center)
                        .focused($isNameFieldFocused)
                        .submitLabel(.done)
                        .cornerRadius(12)
                        .onSubmit {
                            isNameFieldFocused = false
                        }
                        .padding(.horizontal)
                }
                
                if isSyncing {
                    VStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                            .scaleEffect(1.0)
                        
                        Text(downloadLabel)
                            .font(.verlagBoldAdaptive(size: 18))
                            .foregroundColor(Color.primaryText)
                        
                        ProgressView(value: progress, total: 1.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color.primaryText))
                            .background(Color.neutralBg)
                            .foregroundColor(Color.primaryText)
                            .padding(2)
                        
                        Text("\(Int(progress * 100))% Completed")
                            .font(.verlagBoldAdaptive(size: 16))
                            .foregroundColor(Color.primaryText)
                    }
                }
                
                if !isSyncing {
                    HStack {
                        Spacer()
                        Button(action: {
                            isNameFieldFocused = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                goOffline()
                            }
                        }) {
                            Text(stringManager.strings?.dialogGoOffline.continueField ?? StringConstants.Common.continueTextAlert)
                                .font(.verlagBoldAdaptive(size: 30))
                                .foregroundColor(isContinueDisabled ? Color.neutralBg : Color.primaryText)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .opacity(isContinueDisabled ? 0.6 : 1.0)
                        .background(Color.secondaryBg)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 5)
                        .disabled(isContinueDisabled)
                        Spacer()
                    }.padding(.top)
                        .padding(.horizontal)
                    HStack {
                        Button(action: {
                            isNameFieldFocused = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isPresented = false
                            }
                        }) {
                            Text(stringManager.strings?.dialogGoOffline.cancel ?? StringConstants.Common.cancel)
                                .font(.verlagBoldAdaptive(size: 30))
                                .foregroundColor(Color.primaryText)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .background(Color.clear)
                        .padding(.horizontal)
                        .disabled(isSyncing)
                    }
                }
                Spacer()
            }
        }
        .frame(width: UIScreen.main.bounds.width,height:UIScreen.main.bounds.height * 0.6)
    }
    
    func isValidName(_ name: String) -> Bool {
        let pattern = "^[A-Za-z]+([ '-][A-Za-z]+)*$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: name.utf16.count)
        return regex?.firstMatch(in: name, options: [], range: range) != nil
    }
    
    private func goOffline() {
        guard name.count >= 5 else { return }
        isSyncing = true
        progress = 0.0
        downloadLabel = stringManager.strings?.dialogGoOffline.preparing ?? "Preparing Download"
        
        IQAPIClient.getAllDataOffline(code: savedShowCode ?? "", username: name) { result in
            switch result {
            case .success(let response):
                if let responseDict = response as? [String: Any],
                   let success = responseDict["valid"] as? Bool,
                   !success {
                    DispatchQueue.main.async {
                        isSyncing = false
                        isPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.errorMessage = responseDict["message"] as? String ?? "There was an issue going offline. Please try again."
                            showOfflineAlert = true
                        }
                    }
                    return
                }
                if let orderDetails = response as? [String: Any] {
                    DispatchQueue.global(qos: .userInitiated).async {
                        DispatchQueue.main.async {
                            downloadLabel = stringManager.strings?.dialogGoOffline.downloading ?? "Downloading Database"
                        }
                        DRTDatabaseManager.shared.syncServerData(
                            serverDict: orderDetails,
                            progressBlock: { syncProgress in
                                DispatchQueue.main.async {
                                    self.progress = min(CGFloat(syncProgress), 0.99)
                                }
                            },
                            completionBlock: { success, error in
                                DispatchQueue.main.async {
                                    isSyncing = false
                                    progress = 1.0
                                    if success {
                                        isOfflineMode = true
                                        isPresented = false
                                        showOfflineSuccessAlert = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            withAnimation {
                                                showOfflineSuccessAlert = false
                                            }
                                        }
                                    } else {
                                        isPresented = false
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            showOfflineAlert = true
                                        }
                                    }
                                }
                            }
                        )
                    }
                } else {
                    DispatchQueue.main.async {
                        isSyncing = false
                        isPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showOfflineAlert = true
                        }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    isSyncing = false
                    isPresented = false
                    if NetworkMonitor.shared.isNetworkAvailable() {
                        viewModel.errorMessage = error.localizedDescription
                    } else {
                        viewModel.errorMessage = StringManager.shared.strings?.noInternet.description ?? StringConstants.Common.noInternetError
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showOfflineAlert = true
                    }
                }
            }
        }
    }
}

// Publisher extension to observe keyboard height changes
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .map { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0 }
        
        let willHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}
