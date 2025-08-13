//
//  ShowOfflineSuccesAlertView.swift
//  DRTScanner
//
//  Created by IE15 on 01/08/25.
//
import SwiftUI

struct ShowOfflineSuccesAlertView: View {
    @EnvironmentObject var stringManager: StringManager
    var body: some View {
        VStack(alignment: .center) {
            Spacer()
            HStack {
                Spacer()
                Text(stringManager.strings.offline.success)
                    .font(.verlagBoldAdaptive(size: 30))
                    .foregroundColor(Color.primaryText)
                    .padding(.bottom, 10)
                    .padding(.top, 20)
                
                Spacer()
            }
            
            VStack {
                Text(stringManager.strings.offline.download)
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
}
