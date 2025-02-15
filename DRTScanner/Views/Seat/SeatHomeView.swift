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
                            CustomCellView(imageName: "order_number_icon", title: "Look UP By", subtitle: "ORDER NUMBER", buttonImage: "right_side_arrow") {
                                selectedLookupType = .orderNumber
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showLookupAlert = true
                                }
                            }
                            CustomCellView(imageName: "last_name_icon", title: "Look UP By", subtitle: "NAME",  buttonImage: "right_side_arrow") {
                                selectedLookupByName = .name
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showLookupAlertByName = true
                                }
                            }
                            CustomCellView(imageName: "phone_number_icon", title: "Look UP By", subtitle: "PHONE NUMBER",  buttonImage: "right_side_arrow") {
                                selectedLookupType = .phoneNumber
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showLookupAlert = true
                                }
                            }
                            CustomCellView(imageName: "credit_card_icon", title: "Look UP By", subtitle: "CREDIT CARD",  buttonImage: "right_side_arrow") {
                                selectedLookupType = .creditCard
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showLookupAlert = true
                                }
                            }
                            CustomCellView(imageName: "seat_icon", title: "Look UP By", subtitle: "SEAT", bottomLineColor: .customWhite,  buttonImage: "right_side_arrow") {
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
                            Text("Dance Recital Ticketing")
                                .font(Font.custom("Verlag-Book", size: 12))
                                .foregroundColor(.customWhite)
                            Text("2016 DANCE NATIONALS")
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
    }
}

struct SeatHomeView_Previews: PreviewProvider {
    static var previews: some View {
        SeatHomeView(showSeatView: .constant(true))
    }
}
