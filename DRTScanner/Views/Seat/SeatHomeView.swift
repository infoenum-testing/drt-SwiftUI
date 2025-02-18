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
    @State private var selectedLookupType: LookupType = .orderNumber
    @State private var selectedLookupByName: LookupByName = .name

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
                                selectedLookupType = .orderNumber
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
                                selectedLookupType = .phoneNumber
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showLookupAlert = true
                                }
                            }
                            CustomCellView(imageName: StringConstants.SeatHomeView.creditCardIcon, title: StringConstants.SeatHomeView.lookUpBy, subtitle: StringConstants.SeatHomeView.creditCard,  buttonImage: StringConstants.SeatHomeView.rightSideArrow) {
                                selectedLookupType = .creditCard
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
                    }
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
        }
        .navigationBarHidden(isSideMenuPresented)
        .customSheetView(isPresented: $showLookupAlert) {
            LookupByNumbersView(isPresented: $showLookupAlert, lookupType: selectedLookupType).background(Color.showCodeButton).padding(.top, 0)
        }
        .customSheetView(isPresented: $showLookupAlertByName) {
            LookupByNameView(isPresented: $showLookupAlertByName, lookupType: selectedLookupByName).background(Color.showCodeButton).padding(.top, 0)
        }
        .customSheetView(isPresented: $showLookupAlertBySeat) {
            SeatLookupView(isPresented: $showLookupAlertBySeat).padding(.top, 0)
        }
        .sideMenuViewModify(isPresented: $isSideMenuPresented) {
            SideMenuView(isPresented: $isSideMenuPresented)
        }

        .customAlert(isPresented: $showAlert) {
                    GeometryReader { geometry in
                        VStack(alignment: .center) {
                            HStack {
                                Spacer()
                                Text(StringConstants.Common.confirm)
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
                                Text(StringConstants.SeatHomeView.areYouSureYouWantToLogout)
                                    .font(Font.custom("Verlag-Book", size: 18))
                                    .foregroundColor(.white)
                                    .padding([.leading, .trailing, .bottom])
                            }

                            HStack {
                                Text(StringConstants.Common.logout)
                                    .font(Font.custom("Verlag-Bold", size: 20))
                                    .foregroundColor(.showCodeText)
                                    .padding(.leading, 30)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showAlert = false
                                            showSeatView = false
                                            // DRTUser.logout()
                                            showSeatView = false
                                        }
                                    }
                                Spacer()
                                Text(StringConstants.Common.cancel)
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
                        .padding(.top, 100)
                        .padding(.trailing, 20)
                        .background(Color.showCodeButton)
                        .position(x: geometry.size.width / 2, y: geometry.safeAreaInsets.top + 0)
                    }
                }
    }
}

struct SeatHomeView_Previews: PreviewProvider {
    static var previews: some View {
        SeatHomeView(showSeatView: .constant(true))
    }
}
