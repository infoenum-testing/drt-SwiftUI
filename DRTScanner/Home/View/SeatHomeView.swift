//
//  SeatHomeView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/02/25.
//

import SwiftUI

// Main view for seat management and scanning
struct SeatHomeView: View {
    // Used to dismiss the current view
    @Environment(\.presentationMode) var presentationMode
    // Indicates if the app is in offline mode
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    // Indicates if the user is logged in
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    // Stores the show code
    @AppStorage("showCode") private var savedShowCode: String?
    // Stores the show ID
    @AppStorage("showId") private var savedShowId: String?
    // Stores the show name
    @AppStorage("show") private var savedShow: String = ""
    // Controls the side menu presentation
    @State private var isSideMenuPresented = false
    // Controls the visibility of the seat view (passed from parent)
    @Binding var showSeatView: Bool
    // Indicates if the merchandise mode is active
    @AppStorage("isMerchandise") private var isMerchandise: Bool = false
    // Controls the display of the logout/alert dialog
    @State private var showAlert = false
    // Controls the display of the order number lookup view
    @State private var showOrderNumberView = false
    // Controls the display of the lookup alert (by number)
    @State private var showLookupAlert = false
    // Controls the display of the lookup alert (by name)
    @State private var showLookupAlertByName = false
    // Controls the display of the lookup alert (by seat)
    @State private var showLookupAlertBySeat = false
    // ViewModel for seat home logic
    @StateObject private var seatHomeViewModel  =  SeatHomeViewModel()
    // Stores the selected lookup type by name
    @State private var selectedLookupByName: LookupByName = .name
    // Controls the display of the go offline view
    @State private var showGoOfflineView = false
    // Controls the display of the scanning stats view
    @State private var showScanningStatsView = false
    // Controls the display of the about view
    @State private var showAboutView = false
    // Controls the display of the offline error alert
    @State private var showOfflineAlert = false
    // Controls the display of the offline success alert
    @State private var showOfflineSuccessAlert = false
    // Stores the last scanned barcode
    @State private var scannedBarcode: String? = nil
    // Indicates if the ticket is valid
    @State private var isTicketValid: Bool = false
    // Indicates if the ticket was previously scanned
    @State private var isPreScanned: Bool = false
    // Indicates if the ticket is invalid
    @State private var isInvalidTicket: Bool = false
    // Indicates if the seat ticket is invalid
    @State private var isInvalidSeatTicket: Bool = false
    // Indicates if the merchandise ticket is invalid
    @State private var isInvalidMerchTicket: Bool = false
    // Stores the order name
    @State private var orderName: String = ""
    // Stores the order number
    @State private var orderNumber: String = ""
    // Stores the date/time the order was scanned
    @State private var orderDateScanned: String = "" {
        didSet {
            print(_orderDateScanned)
            print(orderDateScanned)
        }
    }
    // Stores error messages
    @State private var errorMessage : String = ""
    @State private var invalidMessage : String = ""
    // Indicates if the ticket is a golden ticket
    @State private var isGoldenTicket: Bool = false
    // Indicates if the merchandise ticket is valid
    @State private var isMerchTicketValid: Bool = false
    // Indicates if the merchandise ticket was previously scanned
    @State private var isMerchPreScanned: Bool = false
    // Controls full screen mode for the scanner
    @State private var isFullScreen: Bool = false
    // Controls whether the scanner is active
    @State private var isScanningCell = true
    @State private var isLoading = false
    // ViewModel to trigger scanner reset
    @StateObject private var scnanerReset = ScannerViewModel()
    @State private var isLoadingSvgImage = false
    @State private var merchOrderName = ""
    @State private var merchVariantName = ""
    @State var scannerLineAnimation: Bool = true
    @StateObject private var viewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @ObservedObject var landingView:LandingViewModel
    @AppStorage("deviceScanCount") private var deviceScanCount: Int = 0
    @EnvironmentObject var stringManager: StringManager
    
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
                                AppBackGroundView(width:UIScreen.main.bounds.width , height: UIDevice.current.userInterfaceIdiom == .pad ? (UIDevice.isLandscape ? 90.adaptiveForIpad : 90.adaptiveForIpad + topSafeAreaPaddingHeader() - 15) : 90.adaptiveForIpad + topSafeAreaPaddingHeader() - 15)
                                HStack {
                                    Text("")
                                        .frame(width: 25, height: 25)
                                    Spacer()
                                    AppLogoView(width: 120.adaptiveForIpad, height: 65.adaptiveForIpad)
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
                                            .padding(.top, UIDevice.isIpad ? 80 : 0)
                                        
                                    }
                                    .padding(.trailing, 20)
                                }
                                .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 0 : topSafeAreaPaddingHeader() - 10)
                            }
                            .clipped()
                            .frame(width: UIScreen.main.bounds.width,height: UIDevice.current.userInterfaceIdiom == .pad ? (UIDevice.isLandscape ? 90.adaptiveForIpad : 80.adaptiveForIpad + topSafeAreaPaddingHeader() - 15) : 90.adaptiveForIpad + topSafeAreaPaddingHeader() - 15)
                            .padding(.top,-10)
                            // Bottom row: show name
                            HStack {
                                Spacer()
                                Text(savedShow)
                                    .font(.verlagBoldAdaptive(size: 20))
                                    .foregroundColor(Color.primaryText)
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
                            ScannerView(seat: $seatHomeViewModel.selectedSeat, scannerLineAnimation: $scannerLineAnimation, isTicketValid: $isTicketValid, isPreScanned: $isPreScanned, isInvalidTicket: $isInvalidTicket, orderName: $orderName, orderNumber: $orderNumber, merchOrderName: $merchOrderName, merchVariantName: $merchVariantName, orderDateScanned: $orderDateScanned, invalidMessage: $invalidMessage, isMerchTicketValid: $isMerchTicketValid, isFullScreen: $isFullScreen, isScanningCell: $isScanningCell,isGoldenTicket: $isGoldenTicket, isInvalidSeatTicket: $isInvalidSeatTicket, isInvalidMerchTicket: $isInvalidMerchTicket, isMerchPreScanned: $isMerchPreScanned, scannerViewModel: scnanerReset, lookupByOrderResultViewModel: viewModel, landingView:landingView,controller: controller, showOfflineAlert: $showOfflineAlert)
                                .frame(width: UIScreen.main.bounds.width)
                                .frame(maxHeight: isFullScreen ? .infinity : nil)
                                .modifier(ConditionalEdgeIgnore(isFullScreen: isFullScreen))
                            
                            // Scrollable area containing lookup options and ticket status views
                            ScrollView(showsIndicators: false) {
                                // Show lookup options only if no ticket state is currently active
                                if !isTicketValid && !isInvalidTicket && !isMerchTicketValid && !isInvalidSeatTicket && !isInvalidMerchTicket && !isMerchPreScanned {
                                    // List of lookup methods (order number, name, phone, credit card, seat)
                                    VStack(spacing: 0) {
                                        // Lookup by order number
                                        CustomCellView(imageName: StringConstants.SeatHomeView.orderNumberIcon, title: stringManager.strings?.home.lookUpBy ?? StringConstants.SeatHomeView.lookUpBy, subtitle: stringManager.strings?.home.orderNumber ?? StringConstants.SeatHomeView.orderNumber, cellHeight: dynamicCellHeight, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                            // Set lookup type and show alert for order number
                                            seatHomeViewModel.selectedLookupType = .orderNumber
                                            isScanningCell = false
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showLookupAlert = true
                                            }
                                        }.padding(.top)
                                        // Lookup by name
                                        CustomCellView(imageName: StringConstants.SeatHomeView.lastNameIcon, title: stringManager.strings?.home.lookUpBy ?? StringConstants.SeatHomeView.lookUpBy, subtitle: stringManager.strings?.home.name ?? StringConstants.SeatHomeView.name,
                                                       cellHeight: dynamicCellHeight, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                            // Set lookup type and show alert for name
                                            selectedLookupByName = .name
                                            isScanningCell = false
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showLookupAlertByName = true
                                            }
                                        }
                                        // Lookup by phone number
                                        CustomCellView(imageName: StringConstants.SeatHomeView.phoneNumberIcon, title: stringManager.strings?.home.lookUpBy ?? StringConstants.SeatHomeView.lookUpBy, subtitle: stringManager.strings?.home.phoneNumber ?? StringConstants.SeatHomeView.phoneNumber,
                                                       cellHeight: dynamicCellHeight, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                            // Set lookup type and show alert for phone number
                                            seatHomeViewModel.selectedLookupType = .phoneNumber
                                            isScanningCell = false
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showLookupAlert = true
                                            }
                                        }
                                        // Lookup by credit card
                                        CustomCellView(imageName: StringConstants.SeatHomeView.creditCardIcon, title: stringManager.strings?.home.lookUpBy ?? StringConstants.SeatHomeView.lookUpBy, subtitle: stringManager.strings?.home.creditCard ?? StringConstants.SeatHomeView.creditCard,
                                                       cellHeight: dynamicCellHeight,
                                                       bottomLineColor: isMerchandise ? Color.neutralBg : Color.primaryText, buttonImage: StringConstants.SeatHomeView.rightSideArrow,
                                                       showDivider: isMerchandise ? false : true
                                        ) {
                                            // Set lookup type and show alert for credit card
                                            seatHomeViewModel.selectedLookupType = .creditCard
                                            isScanningCell = false
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showLookupAlert = true
                                            }
                                        }
                                        // Lookup by seat (only if not in merchandise mode)
                                        if !isMerchandise {
                                            CustomCellView(imageName: StringConstants.SeatHomeView.seatIcon, title: stringManager.strings?.home.lookUpBy ?? StringConstants.SeatHomeView.lookUpBy, subtitle: stringManager.strings?.home.seat ?? StringConstants.SeatHomeView.seat, cellHeight: dynamicCellHeight , bottomLineColor: Color.neutralBg,
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
                                // Show ticket status views if not in full screen mode
                                if !isFullScreen {
                                    // Show previously scanned ticket view if ticket is valid and already scanned
                                    if isTicketValid {
                                        if isPreScanned {
                                            PreviouslyScannedTicketView(orderName: orderName, orderNumber: orderNumber, scannedTime: orderDateScanned, isInFullScreen: false,backGround:Color.previous)
                                        } else {
                                            // Show valid ticket view
                                            ValidTicketView(orderName: orderName, orderNumber: orderNumber, isGoldenTicket: isGoldenTicket, isInFullScreen: false,backGround:Color.valid)
                                        }
                                    } else if isInvalidTicket {
                                        // Show invalid ticket view
                                        InvalidTicketView(message: invalidMessage, isInFullScreen: false,backGround:Color.invalid)
                                    }
                                    //                            else if isMerchandise {
                                    // Show merchandise-related ticket status views
                                    if isMerchPreScanned {
                                        PreviousMerchandiseScanView(name: merchOrderName, variantName: merchVariantName, message: orderDateScanned, isInFullScreen: false,backGround:Color.previous)
                                    }
                                    if isMerchTicketValid {
                                        MerchandiseScanView(variantName: merchVariantName, name: merchOrderName, isInFullScreen: false,backGround:Color.valid)
                                    }
                                    if isInvalidMerchTicket {
                                        InvalidMerchandiseTicketView(isInFullScreen: false,backGround:Color.invalid)
                                    }
                                    // Show invalid seat ticket view
                                    if isInvalidSeatTicket {
                                        InvalidSeatTicketView(message: invalidMessage, isInFullScreen: false,backGround:Color.invalid)
                                    }
                                    //                            }
                                }
                            }.scrollDisabled(UIDevice.current.userInterfaceIdiom == .pad && UIDevice.isLandscape ? false : true)
                                .opacity(!isFullScreen ? 1 : 0)
                                .animation(.easeInOut(duration: 0.4), value: isFullScreen)
                                .background(Color.neutralBg)
                                .onChange(of: orderDateScanned) { newValue in
                                    print(newValue)
                                    print(newValue)
                                }
                        }
                        .background(.black)
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
            print("something")
            isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isLoading.toggle()
            }
        })
        .customAlert(isPresented: $showAlert) {
            ZStack {
                VStack(alignment: .center) {
                    Spacer()
                    VStack {
                        Text(isOfflineMode ? stringManager.strings?.dialogLogout.whenOfflineDescription ?? StringConstants.LandingView.isOfflineAlertMessage : stringManager.strings?.dialogLogout.areYouSure ??
                             StringConstants.LandingView.logoutConfirm)
                        .font(isOfflineMode ? .verlagBookAdaptive(size: 18) : .verlagBoldAdaptive(size: 26))
                        .foregroundColor(Color.primaryText)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .lineLimit(isOfflineMode ? 10 : 1)
                        .padding(.top, 20)
                        .padding(.bottom)
                    }
                    
                    VStack {
                        if !isOfflineMode {
                            HStack {
                                Text(stringManager.strings?.dialogLogout.continueField ?? StringConstants.Common.logout)
                                    .font(.verlagBoldAdaptive(size: 30))
                                    .foregroundColor(Color.primaryText)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.secondaryBg)
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 5)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            DeviceManager.shared.deleteDeviceName()
                                            isUserLoggedIn = false
                                            savedShowCode = nil
                                            savedShowId = nil
                                            showAlert = false
                                            showSeatView = false
                                            deviceScanCount = 0
                                            DRTDatabaseManager.shared.deleteSkin()
                                        }
                                    }
                            }
                            HStack {
                                Text(stringManager.strings?.dialogLogout.cancel ?? StringConstants.Common.cancel)
                                    .font(.verlagBoldAdaptive(size: 30))
                                    .foregroundColor(Color.primaryText)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showAlert = false
                                        }
                                    }
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.4)
            .background {
                AppBackGroundView(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.4,shadow: true)
            }
        }
        .customAlert(isPresented: $showOfflineAlert) {
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    Text(StringManager.shared.strings?.errorMassage.error ?? StringConstants.Common.error)
                        .padding(.leading, 20)
                        .font(.verlagBoldAdaptive(size: 30))
                        .foregroundColor(Color.primaryText)
                        .padding(.bottom, 10)
                        .padding(.top, 20)
                    
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showOfflineAlert = false
                        }
                    }) {
                        Image(StringConstants.DRTImages.crossImage)
                            .resizable()
                            .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                            .background(Color.clear)
                            .contentShape(Rectangle())
                    }
                }
                
                VStack {
                    Text(viewModel.errorMessage ?? "")
                        .font(.verlagBookAdaptive(size: 18))
                        .foregroundColor(Color.primaryText)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding([.horizontal,.bottom])
            .padding(.top,topSafeAreaPaddingHeader() - 10)
            .background(Color.secondaryBg)
        }
        .customAlert(isPresented: $showOfflineSuccessAlert) {
            VStack(alignment: .center) {
                Spacer()
                HStack {
                    Spacer()
                    Text(stringManager.strings?.offline.success ?? StringConstants.Common.success)
                        .font(.verlagBoldAdaptive(size: 30))
                        .foregroundColor(Color.primaryText)
                        .padding(.bottom, 10)
                        .padding(.top, 20)
                    
                    Spacer()
                }
                
                VStack {
                    Text(stringManager.strings?.offline.download ?? StringConstants.SeatHomeView.successDbDownloadAlert)
                        .font(.verlagBookAdaptive(size: 18))
                        .foregroundColor(Color.primaryText)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                Spacer()
            }
            .padding()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.25)
            .background {
                AppBackGroundView(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.25, shadow:true)
            }
        }
        .customAlert(isPresented: $stringManager.isShowAlert) {
            // Custom alert for error messages
            VStack(alignment: .center) {
                HStack {
                    Text("")
                        .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                    Spacer()
                    
                    Text(StringManager.shared.strings?.errorMassage.error ?? StringConstants.Common.error)
                        .font(.verlagBoldAdaptive(size: 30))
                        .foregroundColor(Color.primaryText)
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            stringManager.isShowAlert = false
                        }
                    }) {
                        Image(StringConstants.DRTImages.crossImage)
                            .resizable()
                            .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                            .background(Color.clear)
                            .contentShape(Rectangle())
                    }
                }
                
                Text(stringManager.message)
                    .font(.verlagBookAdaptive(size: 18))
                    .foregroundColor(Color.primaryText)
                    .multilineTextAlignment(.center)
                    .padding(.top,5)
                
            }
            .padding([.horizontal,.bottom])
            .padding(.top,topSafeAreaPaddingHeader())
            .background(Color.secondaryBg)
            
        }
        .ignoresSafeArea()
    }
}
