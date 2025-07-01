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
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                Button(action: {
                    isNameFieldFocused = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isPresented = false
                    }
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

            HStack {
                Spacer()
                Text(stringManager.strings?.dialogGoOffline.title ?? StringConstants.SideMenuView.goOffline)
                    .font(.verlagBoldAdaptive(size: 30))
                    .foregroundColor(.customWhite)
                Spacer()
            }

            Text(stringManager.strings?.dialogGoOffline.description ?? StringConstants.SideMenuView.goOfflineViewDiscription)
                .font(.verlagBookAdaptive(size: 18))
                .foregroundColor(Color.customWhite)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)

            if !isSyncing {
                TextField(stringManager.strings?.dialogGoOffline.typeName ?? StringConstants.SideMenuView.goOfflineViewTextFieldText, text: $name)
                    .padding(UIDevice.current.userInterfaceIdiom == .pad ? 20 : 10)
                    .font(.verlagBook(size: 25))
                    .background(Color.customWhite)
                    .foregroundColor(Color.gray)
                    .frame(alignment: .center)
                    .multilineTextAlignment(.center)
                    .focused($isNameFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        isNameFieldFocused = false
                    }
                    .padding(.horizontal)
            }

            if isSyncing {
                VStack(spacing: 8) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.0)

                    Text(downloadLabel)
                        .font(.verlagBoldAdaptive(size: 18))
                        .foregroundColor(.white)

                    ProgressView(value: progress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .background(Color.customWhite)
                        .foregroundColor(.customWhite)
                        .padding(2)

                    Text("\(Int(progress * 100))% Completed")
                        .font(.verlagBoldAdaptive(size: 16))
                        .foregroundColor(.white)
                }
            }

            if !isSyncing {
                HStack {
                    Button(action: {
                        isNameFieldFocused = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            goOffline()
                        }
                    }) {
                        Text(stringManager.strings?.dialogGoOffline.continueField ?? StringConstants.Common.continueTextAlert)
                            .padding()
                            .font(.verlagBoldAdaptive(size: 26))
                            .foregroundColor(isContinueDisabled ? .gray : Color.customGreen)
                    }
                    .disabled(isContinueDisabled)

                    Spacer()

                    Button(action: {
                        isNameFieldFocused = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isPresented = false
                        }
                    }) {
                        Text(stringManager.strings?.dialogGoOffline.cancel ?? StringConstants.Common.cancel)
                            .padding()
                            .font(.verlagBoldAdaptive(size: 26))
                            .foregroundColor(Color.customGreen)
                    }
                    .disabled(isSyncing)
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: UIDevice.current.userInterfaceIdiom == .pad ? UIScreen.main.bounds.height / 1.5 : UIScreen.main.bounds.height / 1.8
        )
        .background(Color.FFCE_62)
        .edgesIgnoringSafeArea(.bottom)
        .offset(y: getKeyboardOffset(for: keyboardHeight))
        .animation(.easeInOut(duration: 0.001), value: keyboardHeight)
        .onReceive(Publishers.keyboardHeight) { height in
            self.keyboardHeight = height
        }
    }

    func isValidName(_ name: String) -> Bool {
        let pattern = "^[A-Za-z]+([ '-][A-Za-z]+)*$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: name.utf16.count)
        return regex?.firstMatch(in: name, options: [], range: range) != nil
    }

    private func getKeyboardOffset(for height: CGFloat) -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        if UIDevice.current.userInterfaceIdiom == .pad {
            return height / 3
        } else {
            switch screenHeight {
            case 812: return height / 4.5
            case 844: return height / 5
            case 896: return height / 30
            case 926: return height / 5.5
            case 932: return height / 6.2
            case 667: return height / 4.0
            default: return height / 6.2
            }
        }
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
                    viewModel.errorMessage = error.localizedDescription
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
