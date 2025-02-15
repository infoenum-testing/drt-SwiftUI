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
    @State private var order: [Orders] = []
    @StateObject var viewModel = LookupByOrderResultViewModel()
    @StateObject var viewModels = LookupByCreditCardResultViewModel()
    @Binding var isPresented: Bool
    let lookupType: LookupType

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

    // Add a computed variable that automatically updates based on inputText
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
                        .font(Font.custom("Verlag-Bold", size: 34))
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
            .padding(.top, 20)
            
            Grid(horizontalSpacing: 0, verticalSpacing: 0.4) {
                ForEach(buttons, id: \.self) { row in
                    GridRow {
                        ForEach(row, id: \.self) { button in
                            HStack {
                                Text(button)
                                    .font(Font.custom("Verlag-Bold", size: 50))
                                    .frame(width: 134, height: 158)
                                    .background(button == "OK" ? Color.showCodeButton : Color.customWhite)
                                    .foregroundColor(button == "OK" ? .customWhite : .showCodeText)
                            }
                            .onTapGesture {
                                handleButtonTap(button)
                            }
                        }
                    }
                }
            }
        }
        .customSheetView(isPresented: $showResultView) {
            if let firstOrder = order.first, lookupType == .phoneNumber || lookupType == .creditCard {
                LookupResultCardOrPhoneView(inputText: inputText,dismissAction: { showResultView = false }, errorMessage: nil, order: firstOrder)
            } else if let firstOrder = order.first {
                LookupOrderResultView(inputText: inputText, dismissAction: { showResultView = false }, errorMessage: nil, order: firstOrder)
            } else {
                LookupOrderResultView(inputText: inputText, dismissAction: { showResultView = false }, errorMessage: "Orders not found.", order: Orders(buyerName: "", cc: "", phone: "", orderId: 0, studioId: 0))
            }
        }
    }
    
    private func handleButtonTap(_ button: String) {
        if button == "OK", isOKButtonEnabled {
            Task {
                do {
                    await viewModel.fetchSeats(c: "289-6385", q: inputText)
                    
                    DispatchQueue.main.async {
                        if let firstOrder = viewModel.orders.first {
                            self.order = [firstOrder]
                            
                            withAnimation(.easeInOut(duration: 0.3)) {
                                self.showResultView = true
                            }
                        } else {
                            self.showResultView = true
                            print("No order found for input: \(inputText)")
                        }
                    }
                } catch {
                    print("Error fetching order: \(error)")
                }
            }
        } else {
            inputText.append(button)
        }
    }
}

#Preview {
    LookupByNumbersView(isPresented: .constant(false), lookupType: .phoneNumber)
}


//struct LookupByNumbersView: View {
//    @Environment(\.dismiss) var dismiss
//    @State private var inputText: String = ""
//    @State private var showResultView: Bool = false
//    @State private var fetchedSeats: [LookupByOrderResultViewModel] = []
//    @State private var order: [Orders] = []
//    @StateObject var viewModel = LookupByOrderResultViewModel()
//    @Binding var isPresented: Bool
//    let lookupType: LookupType
//
//    let buttons = [
//        ["1", "2", "3"],
//        ["4", "5", "6"],
//        ["7", "8", "9"],
//        ["-", "0", "OK"]
//    ]
//
//    var placeholderText: String {
//        switch lookupType {
//        case .orderNumber:
//            return "ORDER NUMBER"
//        case .phoneNumber:
//            return "PHONE NUMBER"
//        case .creditCard:
//            return "CREDIT CARD"
//        }
//    }
//
//    var isOKButtonEnabled: Bool {
//        switch lookupType {
//        case .orderNumber:
//            return !inputText.isEmpty
//        case .phoneNumber:
//            return inputText.count > 2
//        case .creditCard:
//            return inputText.count > 3
//        }
//    }
//
//    var body: some View {
//        VStack {
//            HStack(alignment: .center){
//                Button(action: {
//                    withAnimation(.easeInOut(duration: 0.3)) {
//                        isPresented = false
//                    }
//                }) {
//                    Image("left_side_arrow")
//                }
//                Spacer()
//                
//                ZStack(alignment: .center) {
//                    if !inputText.isEmpty {
//                        Text(placeholderText)
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                            .offset(y: -25)
//                            .animation(.easeInOut, value: inputText.isEmpty)
//                        
//                    }
//                    
//                    TextField("", text: $inputText, prompt: Text(placeholderText).font(.custom("Verlag-Bold", size: 20)))
//                        .font(Font.custom("Verlag-Bold", size: 34))
//                        .multilineTextAlignment(.leading)
//                        .foregroundColor(.customWhite)
//                        .padding(.all, 10)
//                        .padding(.leading)
//                }
//                .frame(height: 50)
//                
//                
//                Button(action: {
//                    if !inputText.isEmpty {
//                        inputText.removeLast()
//                    }
//                }) {
//                    Image("arrow_with_cross_btn")
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 20)
//            
//            Grid(horizontalSpacing: 0, verticalSpacing: 0.4) {
//                ForEach(buttons, id: \.self) { row in
//                    GridRow {
//                        ForEach(row, id: \.self) { button in
//                            HStack {
//                                Text(button)
//                                    .font(Font.custom("Verlag-Bold", size: 50))
//                                    .frame(width: 134, height: 158)
//                                    .background(button == "OK" ? Color.showCodeButton : Color.customWhite)
//                                    .foregroundColor(button == "OK" ? .customWhite : .showCodeText)
//                            }
//                            .onTapGesture {
//                                handleButtonTap(button)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .customSheetView(isPresented: $showResultView) {
//            if lookupType == .phoneNumber || lookupType == .creditCard {
//                LookupResultCardOrPhoneView(dismissAction: { showResultView = false })
//            } else if let firstOrder = order.first {
//                LookupOrderResultView(inputText: inputText, dismissAction: { showResultView = false }, errorMessage: nil, order: firstOrder)
//            } else {
//                LookupOrderResultView(inputText: inputText, dismissAction: { showResultView = false }, errorMessage: "Orders not found.", order: Orders(buyerName: "", cc: "", phone: "", orderId: 0, studioId: 0))
//            }
//        }
//    }
//    
//    private func handleButtonTap(_ button: String) {
//        if button == "OK", isOKButtonEnabled {
//            Task {
//                do {
//                    await viewModel.fetchSeats(c: "289-6385", q: inputText)
//                    
//                    DispatchQueue.main.async {
//                        if let firstOrder = viewModel.seats.first {
//                            self.order = [firstOrder]
//                            
//                            withAnimation(.easeInOut(duration: 0.3)) {
//                                self.showResultView = true
//                            }
//                        } else {
//                            self.showResultView = true
//                            print("No order found for input: \(inputText)")
//                        }
//                    }
//                } catch {
//                    print("Error fetching order: \(error)")
//                }
//            }
//        } else {
//            inputText.append(button)
//        }
//    }
//}

#Preview {
    LookupByNumbersView(isPresented: .constant(false), lookupType: .phoneNumber)
}
