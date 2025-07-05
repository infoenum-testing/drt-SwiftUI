//
//  ShowCodeView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 31/01/25.
//

import SwiftUI

struct ShowCodeView: View {
    @Binding var showSheet: Bool // Controls visibility of the sheet
    var onCodeEntered: (String) -> Void // Callback when code is completed

    @StateObject private var viewModel = ShowCodeViewModel() // ViewModel for handling logic
    @Environment(\.dismiss) var dismiss // Dismiss environment for fallback
    @Environment(\.sizeData) var sizeData
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    
                    // MARK: - QR Scanner View
                    if viewModel.isScannerVisible {
                        CameraScannerView(
                            onScan: { scannedCode in
                                // Handle QR scanned code
                                viewModel.handleScannedCode(scannedCode, onCodeEntered: onCodeEntered) {
                                    showSheet = false
                                }
                            },
                            isScanning: .constant(true)
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                        
                        // MARK: - Close Button Overlay on Scanner
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation {
                                        viewModel.isScannerVisible = false
                                    }
                                }) {
                                    Image(StringConstants.DRTImages.crossImage)
                                        .resizable()
                                        .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                                        .padding()
                                }
                            }
                            Spacer()
                        }
                        
                    } else {
                        // MARK: - Background Image for Code Entry UI
                        Image(StringConstants.DRTImages.backgound)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .edgesIgnoringSafeArea(.all)
                            .padding(.top, -60)
                        
                        // MARK: - Code Entry UI
                        VStack(spacing: 20) {
                            
                            // MARK: - Logo
                            HStack {
                                Image(StringConstants.DRTImages.logo)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200.adaptiveForIpad, height: 60.adaptiveForIpad)
                            }.padding(.top, 20)
                            
                            // MARK: - Code Display and Controls
                            HStack {
                                // Close Button
                                Button(action: {
                                    withAnimation {
                                        showSheet = false
                                    }
                                }) {
                                    Image(StringConstants.DRTImages.crossImage)
                                        .resizable()
                                        .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                                }
                                
                                Spacer()
                                
                                // Disabled TextField Showing Current Code
                                TextField(StringConstants.Common.showCode, text: $viewModel.showCode)
                                    .font(.verlagBoldAdaptive(size: 42))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                                    .background(Color.clear)
                                    .disabled(true)
                                
                                // Backspace Button
                                Button(action: {
                                    viewModel.removeLastCharacter()
                                }) {
                                    Image(StringConstants.DRTImages.arrowWithCrossBtnImage)
                                        .resizable()
                                        .frame(width: 40.adaptiveForIpad, height: 30.adaptiveForIpad)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // MARK: - QR Camera Button
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        viewModel.isScannerVisible = true
                                    }
                                }) {
                                    Image(systemName: "camera.metering.matrix")
                                        .font(.verlagBookAdaptive(size: 25))
                                        .foregroundColor(.customWhite)
                                }
                                Spacer()
                            }
                            .padding(.horizontal, 15)
                            
                            // MARK: - Grid of Buttons for Code Input
                            Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0.5) {
                                ForEach(viewModel.buttons, id: \.self) { row in
                                    GridRow {
                                        ForEach(row, id: \.self) { button in
                                            ZStack {
                                                if button == "OK" {
                                                    // OK button image changes based on state
                                                    Image(viewModel.isOKButtonEnabled ?
                                                          (viewModel.isOKButtonClicked ? "order_number_clicked_btn" : "order_number_unclicked_btn") :
                                                            "order_number_unclicked_btn")
                                                    .resizable()
                                                } else {
                                                    // Letter buttons styling
                                                    Image(viewModel.clickedButton == button ?
                                                          "lookupby_letters_clicked_btn" :
                                                            "lookupby_letters_unclicked_btn")
                                                    .resizable()
                                                }
                                                
                                                // Button Label
                                                Text(button)
                                                    .font(.verlagBoldAdaptive(size: 50))
                                                    .scaleEffect(button.range(of: #"^[A-Z]$"#, options: .regularExpression) != nil ? 0.9 : 1.1)
                                                    .foregroundColor(button == "OK" ? .customWhite : .customGreen)
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .onTapGesture {
                                                // Handle tap for input or confirmation
                                                viewModel.handleButtonTap(button, onCodeEntered: onCodeEntered) {
                                                    withAnimation {
                                                        showSheet = false
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: .infinity)
                            
                        }
                        // MARK: - Safe Area Padding Adjustment
                        .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 0 : geometry.safeAreaInsets.top - 10)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
        }
    }
}
