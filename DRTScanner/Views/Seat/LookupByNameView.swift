//
//  LookupByNameView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 07/02/25.
//

import SwiftUI

enum LookupByName {
    case name
}

struct LookupByNameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var inputText: String = ""
    @Binding var isPresented: Bool
    @State private var showResultView: Bool = false
    @State private var order: [Orders] = []
    @State private var isOKButtonClicked: Bool = false
    @State private var clickedButton: String? = nil
    @StateObject var viewModel = LookupByNameResultViewModel()
    let lookupType: LookupByName
    let buttons = [
        ["A", "B", "C", "D"],
        ["E", "F", "G", "H"],
        ["I", "J", "K", "L"],
        ["M", "N", "O", "P"],
        ["Q", "R", "S", "T"],
        ["U", "V", "W", "X"],
        ["Y", "Z", ".", "OK"]
    ]
    
    var placeholderText: String {
        switch lookupType {
        case .name:
            return "NAME"
        }
    }
    
    var isOKButtonEnabled: Bool {
        return !inputText.isEmpty
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
                
                TextField(placeholderText, text: $inputText)
                    .font(Font.custom("Verlag-Bold", size: 34))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.customWhite)
                    .padding(.all, 10)
                    .padding(.leading)
                
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
                                ZStack {
                                    if button == "OK" {
                                        Image(isOKButtonClicked ? "order_number_clicked_btn" : "order_number_unclicked_btn")
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
                                .frame(width: 100, height: 90)
                            }
                            .onTapGesture {
                                handleButtonTap(button)
                            }
                        }
                    }
                }
            }
        } .customSheetView(isPresented: $showResultView) {
            if let firstOrder = order.first {
                LookupByNameResultView(inputText: inputText, dismissAction: { showResultView = false }, errorMessage: nil, order: firstOrder)
            } else {
                LookupByNameResultView(inputText: inputText, dismissAction: { showResultView = false}, errorMessage: "Not found", order: Orders(buyerName: "", cc: "", phone: "", orderId: 0, studioId: 0))
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
                showResultView = true
                Task {
                    await viewModel.fetchSeats(c: "289-6385", q: inputText)
                    DispatchQueue.main.async {
                        self.order = viewModel.orders
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
