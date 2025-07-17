//
//  OrderNumberView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 06/02/25.
//

import SwiftUI

// Enum to specify the type of lookup (order number, phone number, or credit card)
enum LookupType {
    case orderNumber, phoneNumber, creditCard
}

// Main view for looking up orders by number, phone, or credit card
struct LookupByNumbersView: View {
    // Dismiss environment variable for closing the view
    @Environment(\.dismiss) var dismiss
    // Core Data context
    @Environment(\.managedObjectContext) private var managedObjectContext
    // AppStorage for saved show code
    @AppStorage("showCode") private var savedShowCode: String?
    // State variables for input, loading, and results
    @State private var inputText: String = ""
    @State private var showResultView: Bool = false
    @State private var fetchedSeats: [LookupByOrderResultViewModel] = []
    @State private var order: [OrdersNewApi]?
    // View models for different lookup types
    @StateObject var viewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @StateObject var creditCardViewModel = LookupByCreditCardResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @StateObject var phoneViewModels = LookupByPhoneResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    // Binding to control presentation
    @Binding var isPresented: Bool
    // The type of lookup to perform
    let lookupType: LookupType
    // State for button click effects and loading
    @State private var isOKButtonClicked: Bool = false
    @State private var clickedButton: String? = nil
    @State private var isLoading: Bool = false
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var stringManager: StringManager
    
    // Custom initializer to set up view models and binding
    init(isPresented: Binding<Bool>, lookupType: LookupType) {
        _viewModel = StateObject(wrappedValue: LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext))
        self._isPresented = isPresented
        self.lookupType = lookupType
    }
    
    // Button layout for the keypad
    let buttons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["-", "0", "OK"]
    ]
    
    // Placeholder text based on lookup type
    var placeholderText: String {
        switch lookupType {
        case .orderNumber:
            return stringManager.strings?.home.orderNumber ?? "ORDER NUMBER"
        case .phoneNumber:
            return stringManager.strings?.home.phoneNumber ?? "PHONE NUMBER"
        case .creditCard:
            return stringManager.strings?.home.creditCard ?? "CREDIT CARD"
        }
    }
    
    // Determines if the OK button should be enabled based on input and lookup type
    var isOKButtonEnabled: Bool {
        switch lookupType {
        case .orderNumber:
            return !inputText.isEmpty
        case .phoneNumber:
            return inputText.count > 2
        case .creditCard:
            return inputText.count > 3
        }
    }
    
    // Main body of the view
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    VStack {
                        // Top bar with back button, input field, and delete button
                        HStack(alignment: .center) {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isPresented = false
                                }
                            }) {
                                Image(StringConstants.DRTImages.leftSideArrow)
                                    .foregroundStyle(Color.neutralText)
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
                                
                                TextField("", text: $inputText, prompt: Text(placeholderText).font(.verlagBoldAdaptive(size: 20)))
                                    .font(.verlagBoldAdaptive(size: 40))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.neutralText)
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                    .disabled(true)
                                    .padding(.all, 10)
                            }
                            .frame(height: 50.adaptiveForIpad)
                            
                            Button(action: {
                                if !inputText.isEmpty {
                                    inputText.removeLast()
                                }
                            }) {
                                Image(StringConstants.DRTImages.arrowWithCrossBtnImage)
                                    .foregroundColor(Color.neutralText)
                            }
                        }
                        .padding(.horizontal, 20.adaptiveForIpad)
                        .padding([.top, .bottom], 20.adaptiveForIpad)
                    }.background(Color.neutralBg)
                    // Keypad for entering numbers and OK
                    HStack {
                        VStack(spacing: 1) {
                            ForEach(buttons, id: \.self) { row in
                                HStack(spacing: 0) {
                                    ForEach(row, id: \.self) { button in
                                        ZStack {
                                            if button == "OK" {
                                                Image(isOKButtonEnabled ? (isOKButtonClicked ? "order_number_clicked_btn" : "order_number_unclicked_btn") : "order_number_unclicked_btn")
                                                    .resizable()
                                            } else {
                                                Image(clickedButton == button ? "lookupby_letters_clicked_btn" : "lookupby_letters_unclicked_btn")
                                                    .resizable()
                                            }
                                            
                                            Text(button)
                                                .font(.verlagBoldAdaptive(size: 50))
                                                .foregroundColor(button == "OK" ? .primaryText : Color.primaryBg)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .onTapGesture {
                                            handleButtonTap(button)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .background(Color.neutralBg)
            }
            
            // Show result view if a lookup has been performed
            if showResultView {
                VStack {
                    if let firstOrder = order {
                        if lookupType == .phoneNumber || lookupType == .creditCard {
                            LookupResultCardOrPhoneView(
                                inputText: inputText,
                                dismissAction: { showResultView = false },
                                errorMessage: nil,
                                lookupType: lookupType
                            ).padding(.top, 0)
                        } else {
                            
                            LookupOrderResultView(
                                inputText: inputText,
                                dismissAction: { showResultView = false },
                                errorMessage: nil,
                                order: firstOrder.first
                            ).padding(.top, 0)
                        }
                        
                    } else {
                        LookupOrderResultView(inputText: inputText, dismissAction: { showResultView = false }, errorMessage: StringConstants.Common.ordersNotFound, order: OrdersNewApi(buyerName: "", cc: "", phone: "", orderId: 0, valid: true,goldenTicketText: "", isGoldenTicket: nil, message: "", seats: [], merch: []))
                            .onAppear {
                                order = nil
                            }
                    }
                }
            }
            // Loading overlay when fetching data
            if isLoading {
                ZStack {
                    Color.black.opacity(0.1)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture { }
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                        .font(.title)
                        .padding()
                }
            }
        }
    }
    
    // Handles button taps for keypad and OK button
    private func handleButtonTap(_ button: String) {
        if button == "OK" {
            if isOKButtonEnabled {
                isOKButtonClicked.toggle()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isOKButtonClicked.toggle()
                }
                isLoading = true
                Task {
                    do {
                        switch lookupType {
                        case .creditCard:
                            await creditCardViewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
                            DispatchQueue.main.async {
                                self.order = creditCardViewModel.orders.isEmpty ? [] : [creditCardViewModel.orders.first!]
                            }
                        case .phoneNumber:
                            await phoneViewModels.fetchSeats(c: savedShowCode ?? "", q: inputText)
                            DispatchQueue.main.async {
                                self.order = phoneViewModels.orders.isEmpty ? [] : [phoneViewModels.orders.first!]
                            }
                        case .orderNumber:
                            await viewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
                            DispatchQueue.main.async {
                                self.order = viewModel.orders.isEmpty ? [] : [viewModel.orders.first!]
                            }
                        }
                        DispatchQueue.main.async {
                            self.isLoading = false // Stop loading
                            self.showResultView = true
                        }
                    } catch {
                        print("Error fetching order: \(error)")
                    }
                }
            }
        } else {
            clickedButton = button
            inputText.append(button)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                clickedButton = nil
            }
        }
    }
}

// Preview for SwiftUI canvas
#Preview {
    LookupByNumbersView(isPresented: .constant(false), lookupType: .phoneNumber)
}
