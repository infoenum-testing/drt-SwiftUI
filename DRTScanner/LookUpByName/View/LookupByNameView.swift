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

    let lookupType: LookupByName

    var placeholderText: String {
        switch lookupType {
        case .name:
            return stringManager.strings?.home.name ?? "NAME"
        }
    }

    var isOKButtonEnabled: Bool {
        return !inputText.isEmpty
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
                            .foregroundStyle(Color.neutralText)
                            .padding(.horizontal, 20)
                    }

                    Spacer()

                    ZStack(alignment: .center) {
                        if !inputText.isEmpty {
                            Text(placeholderText)
                                .font(.verlagBookAdaptive(size: 10))
                                .foregroundColor(Color.neutralText)
                                .offset(y: UIDevice.current.userInterfaceIdiom == .pad ? (UIDevice.isLandscape ? -35 : -50) : -25)
                                .animation(.easeInOut, value: inputText.isEmpty)
                        }

                        TextField(
                            "",
                            text: $inputText,
                            prompt: Text(placeholderText)
                                .font(.verlagBoldAdaptive(size: 20))
                                .foregroundColor(Color.black.opacity(0.2))
                        )
                        .font(.verlagBoldAdaptive(size: 34))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.neutralText)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.all, 10)
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
                .padding(.horizontal, 2.adaptiveForIpad)
                .padding([.top, .bottom], 12.adaptiveForIpad)
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
                        Text("Search")
                            .font(.verlagBoldAdaptive(size: 36))
                            .foregroundColor(Color.primaryText)
//                            .padding(.top, 5.adaptiveForIpad)
//                            .font(.verlagBoldAdaptive(size: 30))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.secondaryBg)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 5)
                    }
                }
                .disabled(isSearching || inputText.isEmpty)
                .opacity(inputText.isEmpty ? 0.6 : 1.0)
                .frame(height: geometry.size.height * 0.08)
                .padding(.bottom, UIScreen.main.bounds.height * 0.05)
                .background(Color.primaryText)
                .padding(.horizontal)
                
            }
            .background(Color.primaryText)
            .customSheetView(isPresented: $showResultView) {
                if let firstOrder = order {
                    LookupByNameResultView(
                        inputText: inputText,
                        dismissAction: { showResultView = false },
                        orders: firstOrder,
                        errorMessage: nil
                    )
                } else {
                    LookupByNameResultView(
                        inputText: inputText,
                        dismissAction: { showResultView = false },
                        orders: [],
                        errorMessage: order?.isEmpty ?? true ? "No orders found" : nil
                    )
                }
            }
        }.hideKeyboardOnTap()
    }

    private func performSearch() {
        guard isOKButtonEnabled else { return }

        isSearching = true
        isOKButtonClicked = true

        Task {
            await viewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
            DispatchQueue.main.async {
                self.order = viewModel.orders
                self.showResultView = true
                self.isSearching = false
                self.isOKButtonClicked = false
            }
        }
    }
}


//    var body: some View {
//        VStack {
//            // Top bar with back button, text field, and delete button
//            HStack(alignment: .center){
//                Button(action: {
//                    withAnimation(.easeInOut(duration: 0.3)) {
//                        isPresented = false
//                    }
//                }) {
//                    Image(StringConstants.DRTImages.leftSideArrow)
//                        .padding(.horizontal, 20)
//                }
//                Spacer()
//                ZStack(alignment: .center) {
//                    if !inputText.isEmpty {
//                        Text(placeholderText)
//                            .font(.verlagBookAdaptive(size: 10))
//                            .foregroundColor(.gray)
//                            .offset(y: UIDevice.current.userInterfaceIdiom == .pad ? -50 : -25)
//                            .animation(.easeInOut, value: inputText.isEmpty)
//                    }
//
//                    TextField("", text: $inputText, prompt: Text(placeholderText).font(.verlagBoldAdaptive(size: 20)).foregroundColor(Color.black.opacity(0.2)))
//                        .font(.verlagBoldAdaptive(size: 34))
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(Color.customWhite)
//                        .minimumScaleFactor(0.5)
//                        .lineLimit(1)
//                        .padding(.all, 10)
//                        .disabled(true)
//                }.frame(height: 50.adaptiveForIpad)
//                Button(action: {
//                    if !inputText.isEmpty {
//                        inputText.removeLast()
//                    }
//                }) {
//                    Image(StringConstants.DRTImages.arrowWithCrossBtnImage)
//                        .padding(.horizontal, 20)
//                }
//            } .padding(.horizontal, 2.adaptiveForIpad)
//                .padding([.top, .bottom], 12.adaptiveForIpad)
//            .background(Color.FFCE_62)
//
//            // On-screen keyboard grid
//            Grid(horizontalSpacing: 0, verticalSpacing: 0.8) {
//                ForEach(buttons, id: \.self) { row in
//                    GridRow {
//                        ForEach(row, id: \.self) { button in
//                            HStack {
//                                ZStack {
//                                    if button == "OK" {
//                                        Image(isOKButtonClicked ? "order_number_clicked_btn" : "order_number_unclicked_btn")
//                                            .resizable()
//                                    } else {
//                                        Image(clickedButton == button ? "lookupby_letters_clicked_btn" : "lookupby_letters_unclicked_btn")
//                                            .resizable()
//                                    }
//
//                                    Text(button)
//                                        .font(.verlagBoldAdaptive(size: 50))
//                                        .foregroundColor(button == "OK" ? Color.customWhite : Color.customGreen)
//                                        .frame(maxWidth: .infinity)
//                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
//                            }
//                            .onTapGesture {
//                                handleButtonTap(button)
//                            }
//                        }
//                    }
//                }
//            }.frame(maxHeight: .infinity)
//        }.background(Color.FFCE_62)
//
//        // Custom sheet to show results
//        .customSheetView(isPresented: $showResultView) {
//            if let firstOrder = order {
//                LookupByNameResultView(inputText: inputText, dismissAction: { showResultView = false }, orders: firstOrder, errorMessage: nil)
//            } else {
//                LookupByNameResultView(inputText: inputText, dismissAction: { showResultView = false }, orders: [], errorMessage: order?.isEmpty ?? true ? "No orders found" : nil)
//            }
//        }
//    }
//
//    // Handles button tap events for the on-screen keyboard
//    private func handleButtonTap(_ button: String) {
//        if button == "OK" {
//            if isOKButtonEnabled {
//                isOKButtonClicked.toggle()
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    self.isOKButtonClicked.toggle()
//                }
//                showResultView = true
//                Task {
//                    await viewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
//                    DispatchQueue.main.async {
//                        self.order = viewModel.orders
//                    }
//                }
//            }
//        } else {
//            clickedButton = button
//            inputText.append(button)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                clickedButton = nil
//            }
//        }
//    }
//}
