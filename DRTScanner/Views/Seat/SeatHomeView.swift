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
    @State private var orderName: String = ""
    @State private var orderNumber: String = ""
    @State private var orderDateScanned: String = ""
    @State private var isMerchTicketValid: Bool = false
    @State private var isMerchPreScanned: Bool = false
    @State private var isFullScreen: Bool = false
    
    private var dynamicCellHeight: CGFloat {
           let screenHeight = UIScreen.main.bounds.height
           return isMerchandise ? screenHeight * 0.12 : screenHeight * 0.09
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
                }
                VStack {
                    ScannerView(seat: $seatHomeViewModel.selectedSeat, isTicketValid: $isTicketValid, isPreScanned: $isPreScanned, isInvalidTicket: $isInvalidTicket, orderName: $orderName, orderNumber: $orderNumber, orderDateScanned: $orderDateScanned, isMerchTicketValid: $isMerchTicketValid, isFullScreen: $isFullScreen)
                        .frame(width: UIScreen.main.bounds.width)
                        .frame(maxHeight: isFullScreen ? .infinity : nil)
                        .modifier(ConditionalEdgeIgnore(isFullScreen: isFullScreen))
                                            
                    ScrollView {
                        if !isTicketValid && !isInvalidTicket && !isMerchTicketValid && !isFullScreen {
                            VStack(spacing: 1) {
                                CustomCellView(imageName: StringConstants.SeatHomeView.orderNumberIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.orderNumber, cellHeight: dynamicCellHeight, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                    seatHomeViewModel.selectedLookupType = .orderNumber
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showLookupAlert = true
                                    }
                                }
                                CustomCellView(imageName: StringConstants.SeatHomeView.lastNameIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.name,
                                               cellHeight: dynamicCellHeight, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                    selectedLookupByName = .name
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showLookupAlertByName = true
                                    }
                                }
                                CustomCellView(imageName: StringConstants.SeatHomeView.phoneNumberIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.phoneNumber,
                                               cellHeight: dynamicCellHeight, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                    seatHomeViewModel.selectedLookupType = .phoneNumber
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showLookupAlert = true
                                    }
                                }
                                CustomCellView(imageName: StringConstants.SeatHomeView.creditCardIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.creditCard,
                                               cellHeight: dynamicCellHeight,
                                               bottomLineColor: isMerchandise ? .customWhite : .gray, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                    seatHomeViewModel.selectedLookupType = .creditCard
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showLookupAlert = true
                                    }
                                }
                                if !isMerchandise {
                                    CustomCellView(imageName: StringConstants.SeatHomeView.seatIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.seat, cellHeight: dynamicCellHeight , bottomLineColor: .customWhite,  buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
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
                                    ValidTicketView(orderName: orderName, orderNumber: orderNumber)
                                }
                            } else if isInvalidTicket {
                                InvalidTicketView()
                            }
                            else if isMerchandise {
                                if isMerchPreScanned {
                                    PreviousMerchandiseScanView()
                                }
                                if isMerchTicketValid {
                                    MerchandiseScanView()
                                }
                            }
                        }
                    }
                        .background(Color.customWhite)
                }
            }
            .toolbar {
                if !isFullScreen {
                    ToolbarItem(placement: .principal) {
                        VStack{
                            Image("Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 500, height: 50)
                                .padding(.leading)
                                .padding(.top, 5)
                            
                            Text(savedShow)
                                .font(Font.custom("Verlag-Bold", size: 20))
                                .foregroundColor(Color.white)
                                .padding(.leading)
                        }
                    }
//                    ToolbarItem(placement: .topBarLeading) {
//                        Button(action: {
//                            withAnimation(.easeInOut(duration: 0.3)) {
//                                showAlert = true
//                            }
//                        }) {
//                            Image("Popup_cross_btn")
//                        }
//                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            isSideMenuPresented.toggle()
                        }) {
                            Image("menu_triger")
                        }
                    }
                }
            }
        }
        .customSheetView(isPresented: $showLookupAlert) {
            if let selectedLookupType = seatHomeViewModel.selectedLookupType {
                LookupByNumbersView(isPresented: $showLookupAlert, lookupType: selectedLookupType).background(Color.clear).padding(.top, UIScreen.main.bounds.height * 0.14)
            }
        }
        .customSheetView(isPresented: $showLookupAlertByName) {
            LookupByNameView(isPresented: $showLookupAlertByName, lookupType: selectedLookupByName).background(Color.clear).padding(.top, UIScreen.main.bounds.height * 0.14)
        }
        .customSheetView(isPresented: $showLookupAlertBySeat) {
            SeatLookupView(isPresented: $showLookupAlertBySeat).padding(.top, UIScreen.main.bounds.height * 0.14)
        }
        .sideMenuViewModify(isPresented: $isSideMenuPresented) {
            SideMenuView(isPresented: $isSideMenuPresented, showGoOfflineView: $showGoOfflineView, showScanningStatsView: $showScanningStatsView, showAboutView: $showAboutView, showAlert: $showAlert)
        }
        .customAlert(isPresented: $showGoOfflineView) {
            withAnimation(.easeInOut(duration: 0.3)) {
                GoOfflineView(isPresented: $showGoOfflineView, showOfflineAlert: $showOfflineAlert, showOfflineSuccessAlert: $showOfflineSuccessAlert)
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
        
        .customAlert(isPresented: $showAlert) {
            VStack(alignment: .center) {
                HStack {
                    Spacer()
                    Text(isOfflineMode ? "ALERT" : "Confirm")
                        .padding(.leading, 20)
                        .font(Font.custom("Verlag-Bold", size: 30))
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
                        Image("Popup_cross_btn")
                    }
                }
                
                VStack {
                    Text(isOfflineMode ?
                         "You are currently scanning in OFFLINE MODE and therefore cannot log out. First, find connectivity and go back into online mode. Then you may log out" :
                            "Are you sure you want to log out?")
                    .font(Font.custom("Verlag-Book", size: 18))
                    .foregroundColor(.white)
                }
                
                HStack {
                    if !isOfflineMode {
                        HStack {
                            Text("Logout")
                                .font(Font.custom("Verlag-Bold", size: 20))
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
                                    }
                                }
                            Spacer()
                            Text("Cancel")
                                .font(Font.custom("Verlag-Bold", size: 20))
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
                        .font(Font.custom("Verlag-Bold", size: 30))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                        .padding(.top, 20)
                    
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showOfflineAlert = false
                        }
                    }) {
                        Image("Popup_cross_btn")
                    }
                }
                
                VStack {
                    Text("There was an issue going offline. Please try again.")
                        .font(Font.custom("Verlag-Book", size: 18))
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
                        .padding(.leading, 20)
                        .font(Font.custom("Verlag-Bold", size: 30))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                        .padding(.top, 20)
                    
                    Spacer()
                }
                
                VStack {
                    Text("Database download successfully")
                        .font(Font.custom("Verlag-Book", size: 18))
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

class SeatHomeViewModel: ObservableObject {
    @Published  var selectedLookupType: LookupType?
    @Published var selectedSeat: SeatModel?
}

struct ConditionalEdgeIgnore: ViewModifier {
    var isFullScreen: Bool
    
    func body(content: Content) -> some View {
        if isFullScreen {
            content.edgesIgnoringSafeArea(.top)
        } else {
            content
        }
    }
}
