//
//  ShowCodeView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 31/01/25.
//

import SwiftUI

struct ShowCodeView: View {
    @State private var showCode: String = ""
    @Binding var showSheet: Bool
    var onCodeEntered: (String) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var isScannerVisible = false
    @State private var clickedButton: String? = nil
    private var isOKButtonClicked: Bool {
        clickedButton == "OK"
    }

    private var isOKButtonEnabled: Bool {
        !showCode.isEmpty
    }

    let buttons = [
        ["A", "B", "C"],
        ["D", "E", "F"],
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["-", "0", "OK"]
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isScannerVisible {
                    CameraScannerView(
                        onScan: { scannedCode in
                            onCodeEntered(scannedCode)
                            withAnimation {
                                isScannerVisible = false
                                showSheet = false
                            }
                        },
                        isScanning: .constant(true)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)

                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                withAnimation {
                                    isScannerVisible = false
                                }
                            }) {
                                Image(StringConstants.DRTImages.crossImage)
                                    .resizable()
                                    .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                                    .background(Color.clear)
                                    .contentShape(Rectangle())
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                } else {
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 20) {
                            HStack {
                                Image(StringConstants.DRTImages.logo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200.adaptiveForIpad, height: 60.adaptiveForIpad, alignment: .center)
                                    .padding(.top, 10)
                            }
                        HStack {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showSheet = false
                                }
                            }) {
                                Image(StringConstants.DRTImages.crossImage)
                                    .resizable()
                                    .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                                    .background(Color.clear)
                                    .contentShape(Rectangle())
                            }

                            Spacer()
                            ZStack(alignment: .center) {
                                if !showCode.isEmpty {
//                                    Text(StringConstants.Common.showCode)
//                                        .font(.caption)
//                                        .foregroundColor(.gray)
//                                        .padding(.leading)
//                                        .offset(y: -25)
//                                        .animation(.easeInOut, value: showCode.isEmpty)
                                }
                                TextField(StringConstants.Common.showCode, text: $showCode)
                                    .font(.verlagBoldAdaptive(size: 42))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .background(Color.clear)
                                    .disabled(true)
                            }
                            Button(action: {
                                if !showCode.isEmpty {
                                    showCode.removeLast()
                                }
                            }) {
                                Image("arrow_with_cross_btn")
                                    .resizable()
                                    .frame(width: 40.adaptiveForIpad, height: 30.adaptiveForIpad)
                                    .background(Color.clear)
                                    .contentShape(Rectangle())
                            }
                        }
                        .padding(.horizontal, 20)

                        HStack {
                            Button(action: {
                                withAnimation {
                                    isScannerVisible = true
                                }
                            }) {
                                Image(systemName: "camera.metering.matrix")
                                    .font(.verlagBookAdaptive(size: 25))
                                    .foregroundColor(Color.customWhite)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 15)

                        Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0.5) {
                            ForEach(buttons, id: \.self) { row in
                                GridRow {
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
                                                .scaleEffect(button.range(of: #"^[A-Z]$"#, options: .regularExpression) != nil ? 0.9 : 1.1)
                                                .foregroundColor(button == "OK" ? .customWhite : Color.customGreen)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .onTapGesture {
                                            clickedButton = button

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

                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                                clickedButton = nil
                                            }
                                        }

                                    }
                                }
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
        }
    }
}

#Preview {
    ShowCodeView(showSheet: .constant(true), onCodeEntered: { _ in })
}
