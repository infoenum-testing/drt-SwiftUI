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
    // ViewModel to trigger scanner reset
    @StateObject private var scnanerReset = ScannerViewModel()
    
    @State private var merchOrderName = ""
    @State private var merchVariantName = ""
    
    // ViewModel for lookup by order result
    @StateObject private var viewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    
    @AppStorage("deviceScanCount") private var deviceScanCount: Int = 0
    @EnvironmentObject var stringManager: StringManager
    
    // Computes the dynamic cell height based on device and mode
    private var dynamicCellHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        if UIDevice.current.userInterfaceIdiom == .pad {
            return isMerchandise ? screenHeight * 0.12 : screenHeight * 0.09
        } else {
            return isMerchandise ? screenHeight * 0.12 : screenHeight * 0.09
        }
    }
    
    // Main body of the SeatHomeView, containing the UI layout and navigation logic
    var body: some View {
        NavigationStack {
            ZStack {
                // Shows background image unless in full screen
                if !isFullScreen {
                    Image(StringConstants.DRTImages.backgound)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .zIndex(-1)
                        .animation(.easeInOut(duration: 0.4), value: isFullScreen)
                }
                VStack {
                    // Scanner view for scanning tickets
                    ScannerView(seat: $seatHomeViewModel.selectedSeat, isTicketValid: $isTicketValid, isPreScanned: $isPreScanned, isInvalidTicket: $isInvalidTicket, orderName: $orderName, orderNumber: $orderNumber, merchOrderName: $merchOrderName, merchVariantName: $merchVariantName, orderDateScanned: $orderDateScanned, invalidMessage: $invalidMessage, isMerchTicketValid: $isMerchTicketValid, isFullScreen: $isFullScreen, isScanningCell: $isScanningCell,isGoldenTicket: $isGoldenTicket, isInvalidSeatTicket: $isInvalidSeatTicket, isInvalidMerchTicket: $isInvalidMerchTicket, isMerchPreScanned: $isMerchPreScanned, scannerViewModel: scnanerReset, lookupByOrderResultViewModel: viewModel, showOfflineAlert: $showOfflineAlert)
                        .frame(width: UIScreen.main.bounds.width)
                        .frame(maxHeight: isFullScreen ? .infinity : nil)
                        .padding(.top, scannerTopPadding(isFullScreen: isFullScreen))
                        .modifier(ConditionalEdgeIgnore(isFullScreen: isFullScreen))
                    
                    // Scrollable area containing lookup options and ticket status views
                    ScrollView(showsIndicators: false) {
                        // Show lookup options only if no ticket state is currently active
                        if !isTicketValid && !isInvalidTicket && !isMerchTicketValid && !isInvalidSeatTicket && !isInvalidMerchTicket && !isMerchPreScanned {
                            // List of lookup methods (order number, name, phone, credit card, seat)
                            VStack(spacing: 1) {
                                // Lookup by order number
                                CustomCellView(imageName: StringConstants.SeatHomeView.orderNumberIcon, title: stringManager.strings?.home.lookUpBy ?? StringConstants.SeatHomeView.lookUpBy, subtitle: stringManager.strings?.home.orderNumber ?? StringConstants.SeatHomeView.orderNumber, cellHeight: dynamicCellHeight, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                    // Set lookup type and show alert for order number
                                    seatHomeViewModel.selectedLookupType = .orderNumber
                                    isScanningCell = false
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showLookupAlert = true
                                    }
                                }
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
                                               bottomLineColor: isMerchandise ? .customWhite : .gray, buttonImage: StringConstants.SeatHomeView.rightSideArrow,
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
                                    CustomCellView(imageName: StringConstants.SeatHomeView.seatIcon, title: stringManager.strings?.home.lookUpBy ?? StringConstants.SeatHomeView.lookUpBy, subtitle: stringManager.strings?.home.seat ?? StringConstants.SeatHomeView.seat, cellHeight: dynamicCellHeight , bottomLineColor: .customWhite,
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
                                    PreviouslyScannedTicketView(orderName: orderName, orderNumber: orderNumber, scannedTime: orderDateScanned, isInFullScreen: false)
                                    
                                } else {
                                    // Show valid ticket view
                                    ValidTicketView(orderName: orderName, orderNumber: orderNumber, isGoldenTicket: isGoldenTicket, isInFullScreen: false)
                                }
                            } else if isInvalidTicket {
                                // Show invalid ticket view
                                InvalidTicketView(message: invalidMessage, isInFullScreen: false)
                            }
                            //                            else if isMerchandise {
                            // Show merchandise-related ticket status views
                            if isMerchPreScanned {
                                PreviousMerchandiseScanView(name: merchOrderName, variantName: merchVariantName, message: orderDateScanned, isInFullScreen: false)
                            }
                            if isMerchTicketValid {
                                MerchandiseScanView(variantName: merchVariantName, name: merchOrderName, isInFullScreen: false)
                            }
                            if isInvalidMerchTicket {
                                InvalidMerchandiseTicketView(isInFullScreen: false)
                            }
                            // Show invalid seat ticket view
                            if isInvalidSeatTicket {
                                InvalidSeatTicketView(message: invalidMessage, isInFullScreen: false)
                            }
                            //                            }
                        }
                    }.scrollDisabled(true)
                    // Set opacity and animation for the scroll view
                    .opacity(!isFullScreen ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4), value: isFullScreen)
                    .background(Color.customWhite)
                    .onChange(of: orderDateScanned) { newValue in
                        print(newValue)
                        print(newValue)
                    }
                }/*.padding(.top, topSafeAreaPadding() - 10)*/
            }
            // Toolbar section for the navigation bar
            .toolbar {
                // Only show toolbar if not in full screen mode
                if !isFullScreen {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            // Top row: empty space, logo, and side menu button
                            HStack {
                                Text("")
                                    .frame(width: 25, height: 25)
                                Spacer()
                                Image(StringConstants.DRTImages.logo)
                                    .resizable()
                                    .frame(width: 120.adaptiveForIpad, height: 60.adaptiveForIpad, alignment: .center)
                                    .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 40.adaptiveForIpad : 0)
                                    .padding(.leading, 10)
                                Spacer()
                                Button(action: {
                                    // Toggle side menu
                                    isSideMenuPresented.toggle()
                                }) {
                                    Image("side_menu")
                                        .resizable()
                                        .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                                        .background(Color.clear)
                                        .contentShape(Rectangle())
                                        .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 40.adaptiveForIpad : 0)
                                }
                            }.padding(.top)
                            // Bottom row: show name
                            HStack {
                                Spacer()
                                Text(savedShow)
                                    .font(.verlagBoldAdaptive(size: 20))
                                    .foregroundColor(Color.white)
                                    .padding(.leading, 5)
                                Spacer()
                            }
                            .frame(width: UIScreen.main.bounds.width)
                            .padding(12)
                            .background(Color.FFCE_62)
                        }.padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? 0 : topSafeAreaPadding())
//                            .padding(.top, topSafeAreaPadding() + 30)
                    }
                }
            }
        }
        .customSheetView(isPresented: $showLookupAlert) {
            if let selectedLookupType = seatHomeViewModel.selectedLookupType {
                LookupByNumbersView(isPresented: $showLookupAlert, lookupType: selectedLookupType)
                    .background(Color.clear)
                    .padding(.top, calculatedTopPadding())
            }
        }
        .onChange(of: showLookupAlert) { newValue in
            if newValue == false {
                isScanningCell = true
                scnanerReset.triggerReset()
            }
        }
        .customSheetView(isPresented: $showLookupAlertByName) {
            LookupByNameView(isPresented: $showLookupAlertByName, lookupType: selectedLookupByName)
                .background(Color.clear)
                .padding(.top, calculatedTopPadding())
        }
        .onChange(of: showLookupAlertByName) { newValue in
            if newValue == false {
                isScanningCell = true
                scnanerReset.triggerReset()
            }
        }
        .customSheetView(isPresented: $showLookupAlertBySeat) {
            SeatLookupView(isPresented: $showLookupAlertBySeat)
                .padding(.top, calculatedTopPadding())
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
//        .onChange(of: showGoOfflineView) { newValue in
//            if newValue {
//                isScanningCell = false
//            } else {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//                    isScanningCell = true
//                    scnanerReset.triggerReset()
//                }
//            }
//        }
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
        
        .customAlert(isPresented: $showAlert) {
            ZStack {
//                Image(StringConstants.DRTImages.backgound)
//                    .resizable()
//                    .edgesIgnoringSafeArea(.top)
            VStack(alignment: .center) {
                VStack {
                    Text(isOfflineMode ? stringManager.strings?.dialogLogout.whenOfflineDescription ?? StringConstants.LandingView.isOfflineAlertMessage : stringManager.strings?.dialogLogout.areYouSure ??
                         StringConstants.LandingView.logoutConfirm)
                    .font(isOfflineMode ? .verlagBookAdaptive(size: 18) : .verlagBoldAdaptive(size: 26))
                    .foregroundColor(.white)
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
                                .foregroundColor(Color.customWhite)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.FFCE_62)
                                .cornerRadius(12)
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
                                .foregroundColor(Color.customWhite)
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
                .frame(maxWidth: .infinity)
            }
            .padding()
            
        }
            .background {
                Image(StringConstants.DRTImages.backgound)
                    .resizable()
                    .scaledToFill()
                    .frame(height: UIScreen.main.bounds.height * 0.35)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .edgesIgnoringSafeArea(.top)
            }
        }
        .customAlert(isPresented: $showOfflineAlert) {
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    Text(StringConstants.Common.error)
                        .padding(.leading, 20)
                        .font(.verlagBoldAdaptive(size: 30))
                        .foregroundColor(.white)
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
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
            .background(Color.FFCE_62)
        }
        .customAlert(isPresented: $showOfflineSuccessAlert) {
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    Text(StringConstants.Common.success)
                        .font(.verlagBoldAdaptive(size: 30))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                        .padding(.top, 20)
                    
                    Spacer()
                }
                
                VStack {
                    Text(StringConstants.SeatHomeView.successDbDownloadAlert)
                        .font(.verlagBookAdaptive(size: 18))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
            .background {
                Image(StringConstants.DRTImages.backgound)
                    .resizable()
                    .scaledToFill()
                    .frame(height: UIScreen.main.bounds.height * 0.25)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .edgesIgnoringSafeArea(.top)
            }
        }
        .ignoresSafeArea()
    }
}

struct SeatHomeView_Previews: PreviewProvider {
    static var previews: some View {
        SeatHomeView(showSeatView: .constant(true))
    }
}

extension Notification.Name {
    static let resetCameraView = Notification.Name("resetCameraView")
}
