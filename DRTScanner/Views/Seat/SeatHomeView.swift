//
//  SeatHomeView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/02/25.
//

import SwiftUI

struct SeatHomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    @AppStorage("showId") private var savedShowId: String?
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
    @State private var isTicketValid: Bool = false
    @State private var isPreScanned: Bool = false
    @State private var isInvalidTicket: Bool = false
    @State private var isInvalidSeatTicket: Bool = false
    @State private var isInvalidMerchTicket: Bool = false
    @State private var orderName: String = ""
    @State private var orderNumber: String = ""
    @State private var orderDateScanned: String = ""
    @State private var errorMessage : String = ""
    @State private var isGoldenTicket: Bool = false
    @State private var isMerchTicketValid: Bool = false
    @State private var isMerchPreScanned: Bool = false
    @State private var isFullScreen: Bool = false
    @State private var isScanningCell = true
    @StateObject private var scnanerReset = ScannerViewModel()
    @StateObject private var viewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    
    private var dynamicCellHeight: CGFloat {
           let screenHeight = UIScreen.main.bounds.height
        if UIDevice.current.userInterfaceIdiom == .pad {
               return isMerchandise ? screenHeight * 0.12 : screenHeight * 0.09
           } else {
               return isMerchandise ? screenHeight * 0.12 : screenHeight * 0.09
           }
       }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if !isFullScreen {
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .zIndex(-1)
                        .animation(.easeInOut(duration: 0.4), value: isFullScreen)
                }
                VStack {
                    ScannerView(seat: $seatHomeViewModel.selectedSeat, isTicketValid: $isTicketValid, isPreScanned: $isPreScanned, isInvalidTicket: $isInvalidTicket, orderName: $orderName, orderNumber: $orderNumber, orderDateScanned: $orderDateScanned, isMerchTicketValid: $isMerchTicketValid, isFullScreen: $isFullScreen, isScanningCell: $isScanningCell,isGoldenTicket: $isGoldenTicket, isInvalidSeatTicket: $isInvalidSeatTicket, isInvalidMerchTicket: $isInvalidMerchTicket, scannerViewModel: scnanerReset, lookupByOrderResultViewModel: viewModel, showOfflineAlert: $showOfflineAlert)
                        .frame(width: UIScreen.main.bounds.width)
                        .frame(maxHeight: isFullScreen ? .infinity : nil)
                        .padding(.top, scannerTopPadding(isFullScreen: isFullScreen))
                        .modifier(ConditionalEdgeIgnore(isFullScreen: isFullScreen))
                    
                    ScrollView {
                        if !isTicketValid && !isInvalidTicket && !isMerchTicketValid && !isInvalidSeatTicket && !isInvalidMerchTicket {
                            VStack(spacing: 1) {
                                CustomCellView(imageName: StringConstants.SeatHomeView.orderNumberIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.orderNumber, cellHeight: dynamicCellHeight, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                    seatHomeViewModel.selectedLookupType = .orderNumber
                                    isScanningCell = false
                                    //   scnanerReset.disableFlash()
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showLookupAlert = true
                                    }
                                }
                                CustomCellView(imageName: StringConstants.SeatHomeView.lastNameIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.name,
                                               cellHeight: dynamicCellHeight, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                    selectedLookupByName = .name
                                    isScanningCell = false
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showLookupAlertByName = true
                                    }
                                }
                                CustomCellView(imageName: StringConstants.SeatHomeView.phoneNumberIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.phoneNumber,
                                               cellHeight: dynamicCellHeight, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                    seatHomeViewModel.selectedLookupType = .phoneNumber
                                    isScanningCell = false
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showLookupAlert = true
                                    }
                                }
                                CustomCellView(imageName: StringConstants.SeatHomeView.creditCardIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.creditCard,
                                               cellHeight: dynamicCellHeight,
                                               bottomLineColor: isMerchandise ? .customWhite : .gray, buttonImage: StringConstants.SeatHomeView.rightSideArrow,
                                               showDivider: isMerchandise ? false : true
                                ) {
                                    seatHomeViewModel.selectedLookupType = .creditCard
                                    isScanningCell = false
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showLookupAlert = true
                                    }
                                }
                                if !isMerchandise {
                                    CustomCellView(imageName: StringConstants.SeatHomeView.seatIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.seat, cellHeight: dynamicCellHeight , bottomLineColor: .customWhite,
                                                   buttonImage: StringConstants.SeatHomeView.rightSideArrow,
                                                   showDivider: false
                                    ) {
                                        isScanningCell = false
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showLookupAlertBySeat = true
                                        }
                                    }
                                }
                            }
                        }
                        if !isFullScreen {
                            if isTicketValid {
                                if isPreScanned {
                                    PreviouslyScannedTicketView(orderName: orderName, orderNumber: orderNumber, scannedTime: orderDateScanned)
                                    
                                } else {
                                    ValidTicketView(orderName: orderName, orderNumber: orderNumber, isGoldenTicket: isGoldenTicket)
                                }
                            } else if isInvalidTicket {
                                InvalidTicketView()
                            }
                            //                            else if isMerchandise {
                            if isMerchPreScanned {
                                PreviousMerchandiseScanView()
                            }
                            if isMerchTicketValid {
                                MerchandiseScanView()
                            }
                            if isInvalidMerchTicket {
                                InvalidMerchandiseTicketView()
                            }
                            
                            if isInvalidSeatTicket {
                                InvalidSeatTicketView()
                            }
                            //                            }
                        }
                    }
                    .opacity(!isFullScreen ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4), value: isFullScreen)
                    .background(Color.customWhite)
                }
            }
            .toolbar {
                if !isFullScreen {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            HStack {
                                Text("")
                                    .frame(width: 25, height: 25)
                                Spacer()
                                Image(StringConstants.DRTImages.logo)
                                    .resizable()
                                    .frame(width: 120.adaptiveForIpad, height: 60.adaptiveForIpad, alignment: .center)
                                    .padding(.top, 40.adaptiveForIpad)
                                    .padding(.leading, 10)
                                Spacer()
                                Button(action: {
                                    isSideMenuPresented.toggle()
                                }) {
                                    Image("side_menu")
                                        .resizable()
                                        .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                                        .background(Color.clear)
                                        .contentShape(Rectangle())
                                        .padding(.top, 40.adaptiveForIpad)
                                }
                            }
                            HStack {
                                Spacer()
                                Text(savedShow)
                                    .font(.verlagBoldAdaptive(size: 20))
                                    .foregroundColor(Color.white)
                                    .padding(.leading, 5)
                                Spacer()
                            }
                            .frame(width: UIScreen.main.bounds.width)
                            .padding(10)
                            .background(Color.FFCE_62)
                        }
                    }
                    
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Button(action: {
//                            isSideMenuPresented.toggle()
//                        }) {
//                            Image("side_menu")
//                                .resizable()
//                                .frame(width: 25, height: 25)
//                                .background(Color.clear)
//                                .contentShape(Rectangle())
//                        }
//                    }
                }
            }
        }
        .customSheetView(isPresented: $showLookupAlert) {
            if let selectedLookupType = seatHomeViewModel.selectedLookupType {
                LookupByNumbersView(isPresented: $showLookupAlert, lookupType: selectedLookupType)
                    .background(Color.clear)
                    .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? topSafeAreaPadding() + 150 : topSafeAreaPadding() + 90)
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
                .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? topSafeAreaPadding() + 150 : topSafeAreaPadding() + 90)
        }
        .onChange(of: showLookupAlertByName) { newValue in
            if newValue == false {
                isScanningCell = true
                scnanerReset.triggerReset()
            }
        }
        .customSheetView(isPresented: $showLookupAlertBySeat) {
            SeatLookupView(isPresented: $showLookupAlertBySeat)
                .padding(.top, UIDevice.current.userInterfaceIdiom == .pad ? topSafeAreaPadding() + 150 : topSafeAreaPadding() + 90)
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
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    Text(isOfflineMode ? StringConstants.Common.alert : StringConstants.Common.confirm)
                        .padding(.leading, 20)
                        .font(.verlagBoldAdaptive(size: 30))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                        .padding(.top, 20)
                    
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAlert = false
                            isMerchandise = false
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
                    Text(isOfflineMode ? StringConstants.LandingView.isOfflineAlertMessage :
                            StringConstants.LandingView.logoutConfirm)
                    .font(.verlagBookAdaptive(size: 18))
                    .foregroundColor(.white)
                }
                
                HStack {
                    if !isOfflineMode {
                        HStack {
                            Text(StringConstants.Common.logout)
                                .font(.verlagBoldAdaptive(size: 20))
                                .foregroundColor(Color.customGreen)
                                .padding(.leading, 30)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        DeviceManager.shared.deleteDeviceName()
                                        isUserLoggedIn = false
                                        savedShowCode = nil
                                        savedShowId = nil
                                        showAlert = false
                                        showSeatView = false
                                        DRTDatabaseManager.shared.deleteSkin()
                                    }
                                }
                            Spacer()
                            Text(StringConstants.Common.cancel)
                                .font(.verlagBoldAdaptive(size: 20))
                                .foregroundColor(Color.customGreen)
                                .padding(.trailing, 30)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showAlert = false
                                    }
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .padding()
            .background(Color.FFCE_62)
        }
        .customAlert(isPresented: $showOfflineAlert) {
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    Text("Error")
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
                    Text("Success")
                        .font(.verlagBoldAdaptive(size: 30))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                        .padding(.top, 20)
                    
                    Spacer()
                }
                
                VStack {
                    Text("Database download successfully")
                        .font(.verlagBookAdaptive(size: 18))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
            .background(Color.FFCE_62)
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
