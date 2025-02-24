//
//  OrderNumberView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 06/02/25.
//

import SwiftUI

enum LookupType {
    case orderNumber, phoneNumber, creditCard
}

struct LookupByNumbersView: View {
    @Environment(\.dismiss) var dismiss
    @State private var inputText: String = ""
    @State private var showResultView: Bool = false
    @State private var fetchedSeats: [LookupByOrderResultViewModel] = []
    @State private var order: [Orders]?
    @StateObject var viewModel = LookupByOrderResultViewModel()
    @StateObject var creditCardViewModel = LookupByCreditCardResultViewModel()
    @StateObject var phoneViewModels = LookupByPhoneResultViewModel()
    @Binding var isPresented: Bool
    let lookupType: LookupType
    @State private var isOKButtonClicked: Bool = false
    @State private var clickedButton: String? = nil
    
    let buttons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["-", "0", "OK"]
    ]
    
    var placeholderText: String {
        switch lookupType {
        case .orderNumber:
            return "ORDER NUMBER"
        case .phoneNumber:
            return "PHONE NUMBER"
        case .creditCard:
            return "CREDIT CARD"
        }
    }
    
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
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    VStack {
                        HStack(alignment: .center){
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isPresented = false
                                }
                            }) {
                                Image("left_side_arrow")
                            }
                            Spacer()
                            
                            ZStack(alignment: .center) {
                                if !inputText.isEmpty {
                                    Text(placeholderText)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .offset(y: -25)
                                        .animation(.easeInOut, value: inputText.isEmpty)
                                }
                                
                                TextField("", text: $inputText, prompt: Text(placeholderText).font(.custom("Verlag-Bold", size: 20)))
                                    .font(Font.custom("Verlag-Bold", size: 40))
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.customWhite)
                                    .padding(.all, 10)
                                    .padding(.leading)
                            }
                            .frame(height: 50)
                            
                            Button(action: {
                                if !inputText.isEmpty {
                                    inputText.removeLast()
                                }
                            }) {
                                Image("arrow_with_cross_btn")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding([.top, .bottom], 20)
                    }.background(.showCodeButton)
                    HStack {
                        VStack(spacing: 1) {
                            ForEach(buttons, id: \.self) { row in
                                HStack(spacing: 0) {
                                    ForEach(row, id: \.self) { button in
                                        ZStack {
                                            if button == "OK" {
                                                Image(isOKButtonEnabled ? (isOKButtonClicked ? "order_number_clicked_btn" : "order_number_unclicked_btn") : "order_number_disabled_btn")
                                                    .resizable()
                                            } else {
                                                Image(clickedButton == button ? "lookupby_letters_clicked_btn" : "lookupby_letters_unclicked_btn")
                                                    .resizable()
                                            }
                                            
                                            Text(button)
                                                .font(Font.custom("Verlag-Bold", size: 50))
                                                .foregroundColor(button == "OK" ? .customWhite : .showCodeText)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: 152)
                                        .onTapGesture {
                                            handleButtonTap(button)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .background(.showCodeButton)
            }
            
            if showResultView {
                VStack {
                    if let firstOrder = order {
                        if lookupType == .phoneNumber || lookupType == .creditCard {
                            LookupResultCardOrPhoneView(
                                inputText: inputText,
                                dismissAction: { showResultView = false }, orders: firstOrder,
                                errorMessage: nil,
                                lookupType: lookupType
                            )
                        } else {
                            LookupOrderResultView(
                                inputText: inputText,
                                dismissAction: { showResultView = false },
                                errorMessage: nil,
                                order: firstOrder.first
                            )
                        }
                    } else {
                        LookupOrderResultView(inputText: inputText, dismissAction: { showResultView = false }, errorMessage: StringConstants.Common.ordersNotFound, order: Orders(buyerName: "", cc: "", phone: "", orderId: 0, studioId: 0))
                    }
                }
            }
        }
    }    
    
    private func handleButtonTap(_ button: String) {
        if button == "OK" {
            if isOKButtonEnabled {
                isOKButtonClicked.toggle()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isOKButtonClicked.toggle()
                }
                Task {
                    do {
                        switch lookupType {
                        case .creditCard:
                            await creditCardViewModel.fetchSeats(c: "289-6385", q: inputText)
                            DispatchQueue.main.async { self.order = creditCardViewModel.orders.isEmpty ? [] : [creditCardViewModel.orders.first!] }
                        case .phoneNumber:
                            await phoneViewModels.fetchSeats(c: "289-6385", q: inputText)
                            DispatchQueue.main.async { self.order = phoneViewModels.orders.isEmpty ? [] : [phoneViewModels.orders.first!] }
                        case .orderNumber:
                            await viewModel.fetchSeats(c: "289-6385", q: inputText)
                            DispatchQueue.main.async { self.order = viewModel.orders.isEmpty ? [] : [viewModel.orders.first!] }
                        }
                        self.showResultView = true
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

#Preview {
    LookupByNumbersView(isPresented: .constant(false), lookupType: .phoneNumber)
}
