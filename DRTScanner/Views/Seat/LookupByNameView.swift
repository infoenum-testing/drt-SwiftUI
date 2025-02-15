//
//  LookupByNameView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 07/02/25.
//

import SwiftUICore
import SwiftUI

enum LookupByName {
    case name
}

struct LookupByNameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var inputText: String = ""
    @Binding var isPresented: Bool
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
                                Text(button)
                                    .font(Font.custom("Verlag-Bold", size: 50))
                                    .frame(width: 100, height: 90)
                                    .background(button == "OK" ? Color.showCodeButton : Color.customWhite)
                                    .foregroundColor(button == "OK" ? .white : .showCodeText)
                            }
                            .onTapGesture {
                                handleButtonTap(button)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func handleButtonTap(_ button: String) {
        if button == "OK" {
            if isOKButtonEnabled {
                print("Proceeding with name: \(inputText)")
            }
        } else {
            inputText.append(button)
        }
    }
}
