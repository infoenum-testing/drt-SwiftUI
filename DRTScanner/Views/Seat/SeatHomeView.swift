//
//  SeatHomeView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/02/25.
//

import SwiftUI

struct SeatHomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isSideMenuPresented = false
    @Binding var showSeatView: Bool
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
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    ScannerView().padding(.top, -30)
                    
                    ScrollView {
                        VStack(spacing: 1) {
                            CustomCellView(imageName: StringConstants.SeatHomeView.orderNumberIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.orderNumber, buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                seatHomeViewModel.selectedLookupType = .orderNumber
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showLookupAlert = true
                                }
                            }
                            CustomCellView(imageName: StringConstants.SeatHomeView.lastNameIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.name,  buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                selectedLookupByName = .name
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showLookupAlertByName = true
                                }
                            }
                            CustomCellView(imageName: StringConstants.SeatHomeView.phoneNumberIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.phoneNumber,  buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                seatHomeViewModel.selectedLookupType = .phoneNumber
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showLookupAlert = true
                                }
                            }
                            CustomCellView(imageName: StringConstants.SeatHomeView.creditCardIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.creditCard,  buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                seatHomeViewModel.selectedLookupType = .creditCard
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showLookupAlert = true
                                }
                            }
                            CustomCellView(imageName: StringConstants.SeatHomeView.seatIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.seat , bottomLineColor: .customWhite,  buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showLookupAlertBySeat = true
                                }
                            }
                        }
                    }.background(Color.customWhite)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    ZStack {
                        VStack{
                            Text(StringConstants.SeatHomeView.danceRecitalTicketing)
                                .font(Font.custom("Verlag-Book", size: 12))
                                .foregroundColor(.customWhite)
                            Text(StringConstants.SeatHomeView.danceNationals)
                                .font(Font.custom("Verlag-Bold", size: 18))
                                .foregroundColor(.customWhite)
                        }
                    }.padding()
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAlert = true
                        }
                    }) {
                        Image("Popup_cross_btn")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isSideMenuPresented.toggle()
                    }) {
                        Image("menu_triger")
                    }
                }
            }
            .frame(height: 120)
            .ignoresSafeArea()
        }
        .customSheetView(isPresented: $showLookupAlert) {
            if let selectedLookupType = seatHomeViewModel.selectedLookupType {
                LookupByNumbersView(isPresented: $showLookupAlert, lookupType: selectedLookupType).background(Color.showCodeButton).padding(.top, 0)
            }
        }
        .customSheetView(isPresented: $showLookupAlertByName) {
            LookupByNameView(isPresented: $showLookupAlertByName, lookupType: selectedLookupByName).background(Color.showCodeButton).padding(.top, 0)
        }
        .customSheetView(isPresented: $showLookupAlertBySeat) {
            SeatLookupView(isPresented: $showLookupAlertBySeat).padding(.top, 0)
        }
        .sideMenuViewModify(isPresented: $isSideMenuPresented) {
            SideMenuView(isPresented: $isSideMenuPresented, showGoOfflineView: $showGoOfflineView, showScanningStatsView: $showScanningStatsView, showAboutView: $showAboutView)
        }
        .customAlert(isPresented: $showGoOfflineView) {
            withAnimation(.easeInOut(duration: 0.3)) {
                GoOfflineView(isPresented: $showGoOfflineView)
            }
        }
        .customAlert(isPresented: $showScanningStatsView) {
            withAnimation(.easeInOut(duration: 0.3)) {
                ScanningStatsView(isPresented: $showScanningStatsView)
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
                    Text("Confirm")
                        .padding(.leading, 20)
                        .font(Font.custom("Verlag-Bold", size: 30))
                        .foregroundColor(.white)
                        .padding(.bottom, 10)
                        .padding(.top, 20)
                    
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAlert = false
                        }
                    }) {
                        Image("Popup_cross_btn")
                    }
                }
                
                VStack {
                    Text("Are you sure you want to logout?")
                        .font(Font.custom("Verlag-Book", size: 18))
                        .foregroundColor(.white)
                        .padding([.leading, .trailing, .bottom])
                }
                
                HStack {
                    Text("Logout")
                        .font(Font.custom("Verlag-Bold", size: 20))
                        .foregroundColor(.showCodeText)
                        .padding(.leading, 30)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAlert = false
                                showSeatView = false
                                //DRTUser.logout()
                                showSeatView = false
                            }
                        }
                    Spacer()
                    Text("Cancel")
                        .font(Font.custom("Verlag-Bold", size: 20))
                        .foregroundColor(.showCodeText)
                        .padding(.trailing, 30)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showAlert = false
                            }
                        }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .padding()
            .background(Color.showCodeButton)
        }
//        .ignoresSafeArea()
//        .zIndex(1)
//        .transition(.move(edge: .top))
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        .edgesIgnoringSafeArea(.all)
    }
}

struct SeatHomeView_Previews: PreviewProvider {
    static var previews: some View {
        SeatHomeView(showSeatView: .constant(true))
    }
}

class SeatHomeViewModel: ObservableObject {
    @Published  var selectedLookupType: LookupType?
}
