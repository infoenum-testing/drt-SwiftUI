//
//  LookupByNameView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 07/02/25.
//

import SwiftUI

// Enum to define lookup type
enum LookupByName {
    case name
}

struct LookupByNameView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("showCode") private var savedShowCode: String?
    @State private var inputText: String = ""
    @Binding var isPresented: Bool
    @State private var showResultView: Bool = false
    @State private var order: [OrdersNewApi]?
    @State private var isOKButtonClicked: Bool = false
    @State private var isSearching: Bool = false

    @StateObject var viewModel = LookupByNameResultViewModel(
        managedObjectContext: PersistenceController.shared.container.viewContext
    )
    @EnvironmentObject var stringManager: StringManager
    @Binding var showOfflineAlert: Bool
    @Binding var showAlertText: Bool

    @ObservedObject var resultViewModel: LookupByOrderResultViewModel

    let lookupType: LookupByName

    var placeholderText: String {
        switch lookupType {
        case .name:
            return stringManager.strings.home.name
        }
    }

    var isOKButtonDisable: Bool {
        return  inputText.count < 5 || !inputText.isValidName()
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Top bar with back, text field, and clear button
                HStack(alignment: .center) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isPresented = false
                        }
                    }) {
                        Image(StringConstants.DRTImages.leftSideArrow)
                            .resizable()
                            .frame(width: 20.adaptiveForIpad, height: 30.adaptiveForIpad, alignment: .center)
                            .foregroundStyle(Color.neutralText)
                            .padding(10.adaptiveForIpad)
                    }

                    Spacer()

                    ZStack(alignment: .center) {
                        if !inputText.isEmpty {
                            CustomsText(title: placeholderText, textFont: .verlagBookAdaptive(size: 10), foregroundColour: .neutralText)
                                .offset(y: UIDevice.current.userInterfaceIdiom == .pad ? (UIDevice.isLandscape ? -35 : -50) : -25)
                                .animation(.easeInOut, value: inputText.isEmpty)
                        }

                        TextField(
                            "",
                            text: $inputText,
                            prompt: Text(placeholderText)
                                .font(.verlagBoldAdaptive(size: 20))
                                .foregroundColor(.colorGrayText)
                        )
                        .font(.verlagBoldAdaptive(size: 34))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.neutralText)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.all, 10)
                        .onChange(of: inputText) { newValue in
                            // Allow only alphabets (a-z, A-Z) and spaces
                            let filtered = newValue.filter { $0.isLetter || $0.isWhitespace }
                            if filtered != newValue {
                                inputText = filtered
                            }
                        }
                        .submitLabel(.search)
                        .onSubmit {
                            performSearch()
                        }
                    }
                    .frame(height: 50.adaptiveForIpad)

                    Button(action: {
                        if !inputText.isEmpty {
                            inputText.removeLast()
                        }
                    }) {
                        Image(StringConstants.DRTImages.arrowWithCrossBtnImage)
                            .foregroundColor(Color.neutralText)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.horizontal,15.adaptiveForIpad)
                .frame(maxHeight: 90.adaptiveForIpad)
                .background(Color.neutralBg)

                Spacer()

                // SEARCH BUTTON
                Button {
                    performSearch()
                } label: {
                    if isSearching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                            .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1)
                    } else {
                        CustomsText(title: stringManager.strings.searchResults.search, textFont: .verlagBoldAdaptive(size: 36), foregroundColour: isOKButtonDisable ? .colorButtonText : .primaryText)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isOKButtonDisable ? Color.colorButtonBg : Color.secondaryBg)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 5)
                    }
                }
                .frame(height: UIScreen.main.bounds.height * 0.08)
                .padding(.bottom, UIScreen.main.bounds.height * 0.05)
                .background(Color.primaryText)
                .padding(.horizontal)
                
            }
            .background(Color.primaryText)
            .overlay {
                if showResultView {
                        LookupByNameResultView(
                            inputText: inputText,
                            dismissAction: {
                                withAnimation {
                                    showResultView = false
                                }
                            },
                            errorMessage: nil
                        )
                        .transition(.move(edge: .trailing))
                }
            }
        }.hideKeyboardOnTap()
    }

    private func performSearch() {
        guard !isOKButtonDisable else {
            showOfflineAlert = true
            showAlertText = true
            resultViewModel.errorMessage = stringManager.strings.errorDescriptionMessages.shortNameError
            return
        }

        isSearching = true
        isOKButtonClicked = true

        Task {
            DispatchQueue.main.async {
                withAnimation {
                    self.showResultView = true
                    self.isSearching = false
                    self.isOKButtonClicked = false
                }    
            }
        }
    }
}

