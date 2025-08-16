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
                CustomsText(title: stringManager.strings.offline.success, textFont: .verlagBoldAdaptive(size: 30), foregroundColour: .primaryText)
                    .padding(.bottom, 10)
                    .padding(.top, 20)
                
                Spacer()
            }
            
            VStack {
                CustomsText(title: stringManager.strings.offline.download, textFont: .verlagBookAdaptive(size: 18), foregroundColour: .primaryText, alignment: .center)
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
