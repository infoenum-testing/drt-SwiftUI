//
//  LogoutView.swift
//  DRTScanner
//
//  Created by IE15 on 01/08/25.
//
import SwiftUI

struct LogoutView:View {
    
    @EnvironmentObject var stringManager: StringManager
    
    @AppStorage("deviceScanCount") private var deviceScanCount: Int = 0
    @AppStorage("isOfflineMode") private var isOfflineMode: Bool = false
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    @AppStorage("showId") private var savedShowId: String?
    
    @Binding var showAlert:Bool
    @Binding var showSeatView: Bool
   
    var body: some View {
        ZStack {
            AppBackGroundView(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.4,shadow: true)
            VStack(alignment: .center) {
                Spacer()
                VStack {
                    Text(isOfflineMode ? stringManager.strings.dialogLogout.whenOfflineDescription : stringManager.strings.dialogLogout.areYouSure)
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
                            Text(stringManager.strings.dialogLogout.continueField)
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
                            Text(stringManager.strings.dialogLogout.cancel)
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
    }
}
