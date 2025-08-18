//
//  SeatHomeView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/02/25.
//

import SwiftUI

enum ScanResult {
    case validTicket(orderName: String, orderNumber: String, isGoldenTicket: Bool)
    case preScannedTicket(orderName: String, orderNumber: String, scannedTime: String, tsScannedDate: String)
    case invalidTicket(message: String)
    case validMerch(orderName: String, variantName: String)
    case preScannedMerch(orderName: String, variantName: String, scannedTime: String, tsScannedDate: String)
    case incorrctMerchMode
    case incorrectTicketMode
    case none
}

// Main view for seat management and scanning
struct SeatHomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("show") private var savedShow: String = ""
    @State private var isSideMenuPresented = false
    @Binding var showSeatView: Bool
    @AppStorage("isMerchandise") private var isMerchandise: Bool = false
    @State private var showAlert = false
    @State private var showOrderNumberView = false
    @State private var showLookupAlert = false
    @State private var showLookupAlertByName = false
    @State private var showLookupAlertBySeat = false
    @StateObject private var seatHomeViewModel  =  SeatHomeViewModel()
    @State private var selectedLookupByName: LookupByName = .name
    @State private var showGoOfflineView = false
    @State private var showScanningStatsView = false
    @State private var showAboutView = false
    @State private var showOfflineAlert = false
    @State private var showOfflineSuccessAlert = false
    @State private var scannedBarcode: String? = nil

    @State private var isPreScanned: Bool = false
    @State private var orderName: String = ""
    @State private var orderNumber: String = ""
    @State private var orderDateScanned: String = "" {
        didSet {
            print(_orderDateScanned)
            print(orderDateScanned)
        }
    }
    @State var tsScannedDate: String = ""
    @State private var errorMessage : String = ""
    @State private var invalidMessage : String = ""
    @State private var isGoldenTicket: Bool = false
    @State private var isFullScreen: Bool = false
    @State private var isScanningCell = true
    @State private var isLoading = false
    @StateObject private var scnanerReset = ScannerViewModel()
    @State private var isLoadingSvgImage = false
    @State private var merchOrderName = ""
    @State private var merchVariantName = ""
    @State var scannerLineAnimation: Bool = true
    @StateObject private var viewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @ObservedObject var landingView:LandingViewModel
    @AppStorage("deviceScanCount") private var deviceScanCount: Int = 0
    @EnvironmentObject var stringManager: StringManager
    @State private var scanResult: ScanResult = .none

    let controller = ScannerViewController()
    
    // Computes the dynamic cell height based on device and mode
    private var dynamicCellHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        if UIDevice.current.userInterfaceIdiom == .pad {
            return isMerchandise ? screenHeight * (UIDevice.isLandscape ? 0.18 : 0.11) : screenHeight * (UIDevice.isLandscape ? 0.15 : 0.09)
        } else {
            return isMerchandise ? screenHeight * 0.11 : screenHeight * 0.09
        }
    }
    
    // Main body of the SeatHomeView, containing the UI layout and navigation logic
    var body: some View {
        NavigationStack {
            if isLoading {
                ProgressView().background(Color.clear)
            } else {
                VStack(spacing: 0) {
                    if !isFullScreen {
                        
                        VStack(spacing:0) {
                            // Top row: empty space, logo, and side menu button
                            ZStack {
                                AppBackGroundView(width:UIScreen.main.bounds.width , height: UIDevice.current.userInterfaceIdiom == .pad ? (UIDevice.isLandscape ? 60.adaptiveForIpad : 90.adaptiveForIpad + topSafeAreaPaddingHeader() - 15) : 90.adaptiveForIpad + topSafeAreaPaddingHeader() - 15)
                                HStack {
                                    Text("")
                                        .frame(width: 25, height: 25)
                                        .padding()
                                    Spacer()
                                    AppLogoView(width:UIDevice.isIpad && UIDevice.isLandscape ? 100.adaptiveForIpad : 120.adaptiveForIpad, height: UIDevice.isIpad && UIDevice.isLandscape ? 55.adaptiveForIpad : 65.adaptiveForIpad)
                                        .padding(.leading, 10)
                                    Spacer()
                                    Button(action: {
                                        // Toggle side menu
                                        withAnimation(.easeInOut) {
                                            isSideMenuPresented.toggle()
                                        }
                                    }) {
                                        Image("side_menu")
                                            .resizable()
                                            .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                                            .background(Color.clear)
                                            .contentShape(Rectangle())
                                            .padding()
                                    }
                                    .padding(.top, UIDevice.isIpad ? UIDevice.isLandscape ? 40 : 80 : 0)
                                }
                                .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 0 : topSafeAreaPaddingHeader() - 10)
                            }
                            .clipped()
                            .frame(width: UIScreen.main.bounds.width,height: UIDevice.current.userInterfaceIdiom == .pad ? (UIDevice.isLandscape ? 60.adaptiveForIpad : 80.adaptiveForIpad + topSafeAreaPaddingHeader() - 15) : 90.adaptiveForIpad + topSafeAreaPaddingHeader() - 15)
                            .padding(.top,-10)
                            
                            // Bottom row: show name
                            HStack {
                                Spacer()
                                CustomsText(title: savedShow, textFont: .verlagBoldAdaptive(size: 20), foregroundColour: .primaryText)
                                    .padding(.leading, 5)
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.secondaryBg)
                            
                        }
                        
                    }
                    ZStack {
                        // Shows background image unless in full screen
                        VStack {
                            // Scanner view for scanning tickets
                            ScannerView(seat: $seatHomeViewModel.selectedSeat,
                                        scannerLineAnimation: $scannerLineAnimation,
                                        orderDateScanned: $orderDateScanned,
                                        tsScannedDate: $tsScannedDate,
                                        invalidMessage: $invalidMessage,
                                        isFullScreen: $isFullScreen,
                                        isScanningCell: $isScanningCell,
                                        isGoldenTicket: $isGoldenTicket,
                                        scannerViewModel: scnanerReset,
                                        lookupByOrderResultViewModel: viewModel,
                                        landingView: landingView,
                                        controller: controller,
                                        scanResultEnum: $scanResult,
                                        showOfflineAlert:  $showOfflineAlert)
                            
                            .frame(width: UIScreen.main.bounds.width)
                            .frame(maxHeight: isFullScreen ? .infinity : nil)
                            .modifier(ConditionalEdgeIgnore(isFullScreen: isFullScreen))
                            
                            if !isFullScreen {
                                ScrollView(showsIndicators: false) {
                                    VStack(spacing: 0) {
                                        CustomCellView(imageName: StringConstants.SeatHomeView.orderNumberIcon, title: stringManager.strings.home.lookUpBy, subtitle: stringManager.strings.home.orderNumber, cellHeight: dynamicCellHeight, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                            // Set lookup type and show alert for order number
                                            seatHomeViewModel.selectedLookupType = .orderNumber
                                            isScanningCell = false
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showLookupAlert = true
                                            }
                                        }
                                        // Lookup by name
                                        CustomCellView(imageName: StringConstants.SeatHomeView.lastNameIcon, title: stringManager.strings.home.lookUpBy, subtitle: stringManager.strings.home.name,
                                                       cellHeight: dynamicCellHeight, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                            // Set lookup type and show alert for name
                                            selectedLookupByName = .name
                                            isScanningCell = false
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showLookupAlertByName = true
                                            }
                                        }
                                        
                                        CustomCellView(imageName: StringConstants.SeatHomeView.phoneNumberIcon, title: stringManager.strings.home.lookUpBy, subtitle: stringManager.strings.home.phoneNumber,
                                                       cellHeight: dynamicCellHeight, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                            seatHomeViewModel.selectedLookupType = .phoneNumber
                                            isScanningCell = false
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showLookupAlert = true
                                            }
                                        }
                                        CustomCellView(imageName: StringConstants.SeatHomeView.creditCardIcon, title: stringManager.strings.home.lookUpBy, subtitle: stringManager.strings.home.creditCard,
                                                       cellHeight: dynamicCellHeight,
                                                       bottomLineColor: isMerchandise ? Color.neutralBg : Color.primaryText, buttonImage: StringConstants.SeatHomeView.rightSideArrow,
                                                       showDivider: isMerchandise ? false : true
                                        ) {
                                            seatHomeViewModel.selectedLookupType = .creditCard
                                            isScanningCell = false
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showLookupAlert = true
                                            }
                                        }
                                        
                                        if !isMerchandise {
                                            CustomCellView(imageName: StringConstants.SeatHomeView.seatIcon, title: stringManager.strings.home.lookUpBy, subtitle: stringManager.strings.home.seat, cellHeight: dynamicCellHeight , bottomLineColor: Color.neutralBg,
                                                           buttonImage: StringConstants.SeatHomeView.rightSideArrow,
                                                           showDivider: false
                                            ) {
                                                // Show alert for seat lookup
                                                isScanningCell = false
                                                withAnimation(.easeInOut(duration: 0.3)) {
                                                    showLookupAlertBySeat = true
                                                }
                                            }
                                        }
                                    }
                                }
                                .scrollDisabled(UIDevice.current.userInterfaceIdiom == .pad && UIDevice.isLandscape ? false : true)
                                .opacity(!isFullScreen ? 1 : 0)
                                .animation(.easeInOut(duration: 0.4), value: isFullScreen)
                                .background(Color.neutralBg)
                            }
                        }
                        .background(.black)
                        
                        //MARK: scnner result view
                        VStack {
                            Spacer()
                            Group {
                                switch scanResult {
                                case .validTicket(let orderName, let orderNumber, let isGoldenTicket):
                                    ValidTicketView(orderName: orderName,
                                                    orderNumber: orderNumber,
                                                    isGoldenTicket: isGoldenTicket,
                                                    backGround: Color.valid)
                                    
                                case .preScannedTicket(let orderName, let orderNumber, let scannedTime, let tsScannedDate):
                                    PreviouslyScannedTicketView(orderName: orderName,
                                                                orderNumber: orderNumber,
                                                                scannedTime: scannedTime,
                                                                tsScannedDate: tsScannedDate,
                                                                backGround: Color.previous)
                                    
                                    
                                case .invalidTicket(let message):
                                    InvalidTicketView(message: message,
                                                      backGround: Color.invalid)
                                    
                                case .validMerch(let orderName, let variantName):
                                    MerchandiseScanView(variantName: variantName,
                                                        name: orderName,
                                                        backGround: Color.valid)
                                    
                                case .preScannedMerch(let orderName, let variantName, let scannedTime, let tsScannedDate):
                                    PreviousMerchandiseScanView(name: orderName,
                                                                variantName: variantName,
                                                                message: scannedTime,
                                                                tsScannedDate: tsScannedDate,
                                                                backGround: Color.previous)
                                    
                                case .incorrctMerchMode:
                                    InvalidMerchandiseTicketView(backGround: Color.invalid)
                                    
                                case .incorrectTicketMode:
                                    InvalidSeatTicketView(backGround: Color.invalid)
                                    
                                case .none:
                                    EmptyView() // nothing scanned yet
                                }
                            }
                        }
                    }
                    .overlay {
                        VStack {
                            if showLookupAlert {
                                if let selectedLookupType = seatHomeViewModel.selectedLookupType {
                                    LookupByNumbersView(isPresented: $showLookupAlert, lookupType: selectedLookupType)
                                        .clipped()
                                        .background(Color.primaryText)
                                        .transition(.move(edge: .trailing))
                                        .animation(.easeInOut, value: showLookupAlert)
                                        .onAppear{
                                            scannerLineAnimation = false
                                        }
                                }
                            } else if showLookupAlertByName {
                                LookupByNameView(isPresented: $showLookupAlertByName, lookupType: selectedLookupByName)
                                    .clipped()
                                    .background(Color.primaryText)
                                    .transition(.move(edge: .trailing))
                                    .animation(.easeInOut, value: showLookupAlert)
                                    .onAppear{
                                        scannerLineAnimation = false
                                    }
                            } else if showLookupAlertBySeat {
                                SeatLookupView(isPresented: $showLookupAlertBySeat)
                                    .clipped()
                                    .background(Color.primaryText)
                                    .transition(.move(edge: .trailing))
                                    .animation(.easeInOut, value: showLookupAlert)
                                    .onAppear{
                                        scannerLineAnimation = false
                                    }
                            } else {
                                Rectangle()
                                    .fill(.clear)
                                    .onAppear{
                                        scannerLineAnimation = true
                                    }
                            }
                        }
                        .frame(width:UIScreen.main.bounds.width)
                    }
                }
                .frame(height: UIScreen.main.bounds.height)
                .environmentObject(stringManager)
            }
        }
        
        .onChange(of: showLookupAlert) { newValue in
            if newValue == false {
                isScanningCell = true
                scnanerReset.triggerReset()
            }
        }
        .onChange(of: showLookupAlertByName) { newValue in
            if newValue == false {
                isScanningCell = true
                scnanerReset.triggerReset()
            }
        }
        .onChange(of: showLookupAlertBySeat) { newValue in
            if newValue == false {
                isScanningCell = true
                scnanerReset.triggerReset()
            }
        }
        .sideMenuViewModify(isPresented: $isSideMenuPresented) {
            SideMenuView(isPresented: $isSideMenuPresented, showGoOfflineView: $showGoOfflineView, showScanningStatsView: $showScanningStatsView, showAboutView: $showAboutView, showAlert: $showAlert)
        }
        .onChange(of: isSideMenuPresented) { newValue in
            if newValue {
                isScanningCell = false
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    isScanningCell = true
                        scnanerReset.triggerReset()
                    NotificationCenter.default.post(name: .resetCameraView, object: nil)
                }
            }
        }
        .customAlertGoOffline(isPresented: $showGoOfflineView) {
            withAnimation(.easeInOut(duration: 0.3)) {
                GoOfflineView(isPresented: $showGoOfflineView, showOfflineAlert: $showOfflineAlert, showOfflineSuccessAlert: $showOfflineSuccessAlert, viewModel: viewModel)
            }
        }
        .customAlert(isPresented: $showScanningStatsView) {
            withAnimation(.easeInOut(duration: 0.3)) {
                ScanningStatsView(isPresented: $showScanningStatsView, context: PersistenceController.shared.container.viewContext)
            }
        }
        .customAlert(isPresented: $showAboutView) {
            withAnimation(.easeInOut(duration: 0.3)) {
                AboutView(isPresented: $showAboutView)
            }
        }
        .onChange(of: UIDevice.isLandscape, perform: { newValue in
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isLoading.toggle()
            }
        })
        .customAlert(isPresented: $showAlert) {
            LogoutView(showAlert: $showAlert, showSeatView: $showSeatView)
        }
        .customAlert(isPresented: $showOfflineAlert) {
            ShowOfflineAlertView(viewModel: viewModel, showOfflineAlert: $showOfflineAlert)
        }
        .customAlert(isPresented: $showOfflineSuccessAlert) {
            ShowOfflineSuccesAlertView()
        }
        .customAlert(isPresented: $stringManager.isShowAlert) {
            CustomAlertMessage()
        }
        .ignoresSafeArea()
    }
}
