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
    
#if DEBUG
    @State private var name = "indresh"
#else
    @State private var name = ""
#endif
    
    @State private var isSyncing = false
    @Binding var isPresented: Bool
    @Binding var showOfflineAlert: Bool
    @Binding var showOfflineSuccessAlert: Bool
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    @FocusState private var isNameFieldFocused: Bool
    @State private var keyboardHeight: CGFloat = 0
    @ObservedObject var viewModel: LookupByOrderResultViewModel
    
    var isContinueDisabled: Bool {
        name.count < 5 || isSyncing
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
            HStack {
                Spacer()
                Text(StringConstants.SideMenuView.goOffline)
                    .font(.verlagBoldAdaptive(size: 30))
                    .foregroundColor(.customWhite)
                    .padding(.trailing, -60)
                Spacer()
                Button(action: {
                    isNameFieldFocused = false
                    isPresented = false
                }) {
                    Image(StringConstants.DRTImages.crossImage)
                        .resizable()
                        .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                        .background(Color.clear)
                        .contentShape(Rectangle())
                        .padding()
                }
                .disabled(isSyncing)
            }
            
            Text(StringConstants.SideMenuView.goOfflineViewDiscription)
                .font(.verlagBookAdaptive(size: 18))
                .foregroundColor(Color.customWhite)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
            
            HStack {
                TextField("Type your name here", text: $name)
                    .padding(UIDevice.current.userInterfaceIdiom == .pad ? 20 : 10)
                    .font(.verlagBook(size: 25))
                    .background(Color.customWhite)
                    .foregroundColor(Color.gray)
                    .frame(alignment: .center)
                    .multilineTextAlignment(.center)
                    .disabled(isSyncing)
                    .focused($isNameFieldFocused)
                    .submitLabel(.done) // or .go, .next, etc.
                        .onSubmit {
                            isNameFieldFocused = false
                        }
            }.padding(.horizontal)
            .frame(alignment: .center)
            
            if isSyncing {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.0)
                        .padding(2)
                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .background(Color.customWhite)
                        .foregroundColor(.customWhite)
                        .animation(.easeInOut, value: progress)
                        .padding(2)
                    
                    Text("\(Int(progress * 100))% Completed")
                        .font(.verlagBoldAdaptive(size: 16))
                        .foregroundColor(.white)
                }
            }
            
            HStack {
                Button(action: {
                    isNameFieldFocused = false
                    goOffline()
                }) {
                    Text(StringConstants.Common.continueTextAlert)
                        .padding()
                        .font(.verlagBoldAdaptive(size: 26))
                        .foregroundColor(isContinueDisabled ? .gray : Color.customGreen)
                }
                .disabled(isContinueDisabled)
                
                Spacer()
                
                Button(action: {
                    isNameFieldFocused = false
                    isPresented = false }
                ) {
                    Text(StringConstants.Common.cancel)
                        .padding()
                        .font(.verlagBoldAdaptive(size: 26))
                        .foregroundColor(Color.customGreen)
                }
                .disabled(isSyncing)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 1.8 + keyboardHeight)
        .padding(.bottom, keyboardHeight)
        .background(Color.FFCE_62)
        .edgesIgnoringSafeArea(.bottom)
        Spacer()
        .onReceive(Publishers.keyboardHeight) { height in
                self.keyboardHeight = height
        }
    }
    
    private func goOffline() {
        guard name.count >= 5 else { return }
        
        isSyncing = true
        progress = 0.0
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                if self.progress < 1.0 {
                    self.progress += 0.02
                    self.progress = min(self.progress, 1.0)
                } else {
                    timer.invalidate()
                }
            }
        
        IQAPIClient.getAllDataOffline(code: savedShowCode ?? "", username: name) { result in
            switch result {
            case .success(let response):
                if let responseDict = response as? [String: Any],
                   let success = responseDict["success"] as? Bool,
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
                        DRTDatabaseManager.shared.syncServerData(
                            serverDict: orderDetails,
                            progressBlock: { syncProgress in
                                DispatchQueue.main.async {
                                    self.progress = min(CGFloat(syncProgress), 1.0)
                                }
                            },
                            completionBlock: { success, error in
                                DispatchQueue.main.async {
                                    isSyncing = false
                                    progress = 1.0
                                    
                                    if success {
                                        DispatchQueue.main.async {
                                            isOfflineMode = true
                                            isPresented = false
                                            showOfflineSuccessAlert = true
                                        }
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
                        timer.invalidate()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showOfflineAlert = true
                        }
                    }
                }
                
            case .failure(_):
                DispatchQueue.main.async {
                    isSyncing = false
                    isPresented = false
                    timer.invalidate()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showOfflineAlert = true
                    }
                }
            }
        }
    }
}

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
