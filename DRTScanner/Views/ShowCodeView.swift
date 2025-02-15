//
//  ShowCodeView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 31/01/25.
//

import SwiftUI

struct ShowCodeView: View {
    @State private var showCode: String = "289-6385"
    @Binding var showSheet: Bool
    var onCodeEntered: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    let buttons = [
        ["A", "B", "C"],
        ["D", "E", "F"],
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["-", "0", "OK"]
    ]
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            
            VStack {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showSheet = false
                        }
                    }) {
                        Image("Popup_cross_btn")
                    }
                    Spacer()
                    
                    TextField("Show Code", text: $showCode)
                        .font(Font.custom("Verlag-Bold", size: 42))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .background(Color.clear)
                        .padding(.top, 20)
                    
                    Button(action: {
                        if !showCode.isEmpty {
                            showCode.removeLast()
                        }
                    }) {
                        Image("arrow_with_cross_btn")
                    }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                
                VStack(alignment: .center) {
                    HStack {
                        Button(action: {
                        }) {
                            Image(systemName: "camera.metering.matrix")
                                .font(.system(size: 20))
                                .foregroundColor(.customWhite)
                        }
                        Spacer()
                    }
                    .padding(.leading)
                    .padding(.trailing)
                    .padding(.bottom)
                }
                HStack {
                    Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0.4) {
                        ForEach(buttons, id: \.self) { row in
                            GridRow {
                                ForEach(row, id: \.self) { button in
                                    HStack {
                                        Text(button)
                                            .font(Font.custom("Verlag-Bold", size: 50))
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .aspectRatio(1.2, contentMode: .fill)
                                            .background(button == "OK" ? Color.showCodeButton : Color.customWhite)
                                            .foregroundColor(button == "OK" ? .customWhite : .showCodeText)
                                    }
                                    .onTapGesture {
                                        if button == "OK" {
                                            if !showCode.isEmpty {
                                                onCodeEntered(showCode)
                                                
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    showSheet = false
                                                }
                                            }
                                        } else {
                                            showCode.append(button)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }.padding(.bottom, 100)
            }.padding(.top, 50)
        }
    }
}

#Preview {
    ShowCodeView(showSheet: .constant(true), onCodeEntered: { _ in })
}
