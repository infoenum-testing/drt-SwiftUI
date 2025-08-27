//
//  ShowCodeView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 31/01/25.
//

import SwiftUI

struct ShowCodeView: View {
    @Binding var showSheet: Bool
    var onCodeEntered: (String) -> Void
    @EnvironmentObject var stringManager: StringManager
    @StateObject private var viewModel = ShowCodeViewModel()
    @Environment(\.dismiss) var dismiss
    @Environment(\.sizeData) var sizeData
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    
                    // MARK: - QR Scanner View
                    if viewModel.isScannerVisible {
                        CameraScannerView(
                            isScanning: .constant(true),
                            isSideMenuPresented: .constant(false),
                            controller: ScannerViewController(),
                            onScan: { scannedCode in
                                // Handle QR scanned code
                                viewModel.handleScannedCode(scannedCode, onCodeEntered: onCodeEntered) {
                                    showSheet = false
                                }
                            }
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
                                        .padding(10)
                                }
                            }
                            .padding(.top,topSafeAreaPadding())
                            .padding(.trailing,15)
                            Spacer()
                        }
                        
                    } else {
                        // MARK: - Background Image for Code Entry UI
                        let opacity = 0.00000001
                        AppBackGroundView(width: geometry.size.width,height: geometry.size.height)
                            .disabled(true)
                            .overlay {
                                Color.black.opacity(opacity)
                            }
                        
                        
                        
                        // MARK: - Code Entry UI
                        VStack(spacing: 20) {
                            // MARK: - Logo
                            let width = UIDevice.isIpad && UIDevice.isLandscape ? UIScreen.main.bounds.height * 0.18 : 170.adaptiveForIpad
                            let height = UIDevice.isIpad && UIDevice.isLandscape ? UIScreen.main.bounds.height * 0.1 : 100.adaptiveForIpad
                            AppLogoView(width: width, height: height)
                                .disabled(true)
                                .overlay {
                                    Color.black.opacity(opacity)
                                }
                            // MARK: - Code Display and Controls
                            HStack(alignment: .bottom) {
                                // Close Button
                                Button(action: {
                                    withAnimation {
                                        showSheet = false
                                    }
                                }) {
                                    Image(StringConstants.DRTImages.crossImage)
                                        .resizable()
                                        .frame(width: 30.adaptiveForIpad, height: 30.adaptiveForIpad)
                                        .padding(5)
                                }
                                Spacer()
                                VStack(spacing: 0){
                                    if viewModel.showCode.isEmpty {
                                        CustomsText(title: stringManager.strings.login.showCode, textFont: .verlagBoldAdaptive(size: 15), foregroundColour: .clear)
                                    } else {
                                        CustomsText(title: stringManager.strings.login.showCode, textFont: .verlagBoldAdaptive(size: 15), foregroundColour: .primaryText)
                                    }
                                    // Disabled TextField Showing Current Code
                                    BlinkingCodeDisplay(
                                        placeholder: stringManager.strings.login.showCode,
                                        code: $viewModel.showCode
                                    )
                                    .padding(.top,10)
                                    .frame(maxWidth: .infinity)
                                }

                                // Backspace Button
                                Button(action: {
                                    viewModel.removeLastCharacter()
                                }) {
                                    Image(StringConstants.DRTImages.arrowWithCrossBtnImage)
                                        .resizable()
                                        .foregroundStyle(Color.primaryText)
                                        .frame(width: 40.adaptiveForIpad, height: 30.adaptiveForIpad)
                                        .padding(.horizontal,5)
                                        .padding(.vertical,8)
                                }
                            }
                            .padding(.horizontal, 15.adaptiveForIpad)
                            .background(Color.black.opacity(opacity))
                            //
                            // MARK: - Grid of Buttons for Code Input
                            Grid(alignment: .center, horizontalSpacing: 0, verticalSpacing: 0.5) {
                                ForEach(viewModel.buttons, id: \.self) { row in
                                    GridRow {
                                        ForEach(row, id: \.self) { button in
                                            ZStack {
                                                // Letter buttons styling
                                                Image(viewModel.clickedButton == button ?
                                                      "lookupby_letters_clicked_btn" :
                                                        "lookupby_letters_unclicked_btn")
                                                .resizable()
                                                if button == "OK" {
                                                    Image(.qrcode)
                                                        .resizable()
                                                        .renderingMode(.template)
                                                        .frame(width: 40.adaptiveForIpad, height: 40.adaptiveForIpad, alignment: .center)
                                                        .foregroundColor(Color.primaryBg)
                                                } else {
                                                    Text( button)
                                                        .font(.verlagBoldAdaptive(size: 50))
                                                        .scaleEffect(button.range(of: #"^[A-Z]$"#, options: .regularExpression) != nil ? 0.9 : 1.1)
                                                        .foregroundColor(Color.primaryBg)
                                                }
                                            }
                                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                                            .onTapGesture {
                                                // Handle tap for input or confirmation
                                                viewModel.handleButtonTap(button) {
                                                    withAnimation {
                                                        viewModel.isScannerVisible = true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: .infinity)
                            
                            ZStack {
                                Image(viewModel.isOKButtonEnabled ?
                                      (viewModel.isOKButtonClicked ? "order_number_clicked_btn" : "order_number_unclicked_btn") :
                                        "order_number_unclicked_btn")
                                .resizable()
                                
                                Text("OK")
                                    .font(.verlagBoldAdaptive(size: 50))
                                    .foregroundColor(.primaryText )
                            }
                            .frame(height: UIDevice.isNonNotchIphone ? 90 : 120.adaptiveForIpad)
                            .padding(.top, -20)
                            .onTapGesture {
                                viewModel.okayButtonAction(onCodeEntered: onCodeEntered) {
                                    withAnimation {
                                        showSheet = false
                                    }
                                }
                            }
                        }
                        // MARK: - Safe Area Padding Adjustment
                        .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 0 : topSafeAreaPaddingHeader())
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
        }
    }
}
