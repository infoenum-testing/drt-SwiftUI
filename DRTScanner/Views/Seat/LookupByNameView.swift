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
    @AppStorage("showCode") private var savedShowCode: String?
    @State private var inputText: String = ""
    @Binding var isPresented: Bool
    @State private var showResultView: Bool = false
    @State private var order: [OrdersNewApi]?
    @State private var isOKButtonClicked: Bool = false
    @State private var clickedButton: String? = nil
    @StateObject var viewModel = LookupByNameResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
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
                    Image(StringConstants.DRTImages.leftSideArrow)
                        .padding(.horizontal, 20)
                }
                Spacer()
                ZStack(alignment: .center) {
                    if !inputText.isEmpty {
                        Text(placeholderText)
                            .font(.verlagBookAdaptive(size: 10))
                            .foregroundColor(.gray)
                            .offset(y: UIDevice.current.userInterfaceIdiom == .pad ? -50 : -25)
                            .animation(.easeInOut, value: inputText.isEmpty)
                    }
                    
                    TextField("", text: $inputText, prompt: Text(placeholderText).font(.verlagBoldAdaptive(size: 20)))
                        .font(.verlagBoldAdaptive(size: 34))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.customWhite)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .padding(.all, 10)
                        .disabled(true)
                }.frame(height: 50.adaptiveForIpad)
                Button(action: {
                    if !inputText.isEmpty {
                        inputText.removeLast()
                    }
                }) {
                    Image("arrow_with_cross_btn")
                        .padding(.horizontal, 20)
                }
            } .padding(.horizontal, 2.adaptiveForIpad)
                .padding([.top, .bottom], 12.adaptiveForIpad)
            .background(Color.FFCE_62)
            
            Grid(horizontalSpacing: 0, verticalSpacing: 0.8) {
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
                                        .font(.verlagBoldAdaptive(size: 50))
                                        .foregroundColor(button == "OK" ? Color.customWhite : Color.customGreen)
                                        .frame(maxWidth: .infinity)
                                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            .onTapGesture {
                                handleButtonTap(button)
                            }
                        }
                    }
                }
            }.frame(maxHeight: .infinity)
        }.background(Color.FFCE_62)
        .customSheetView(isPresented: $showResultView) {
            if let firstOrder = order {
                LookupByNameResultView(inputText: inputText, dismissAction: { showResultView = false }, orders: firstOrder, errorMessage: nil)
            } else {
                LookupByNameResultView(inputText: inputText, dismissAction: { showResultView = false }, orders: [], errorMessage: order?.isEmpty ?? true ? "No orders found" : nil)
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
                    await viewModel.fetchSeats(c: savedShowCode ?? "", q: inputText)
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
