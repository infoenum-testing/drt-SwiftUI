//
//  StopScanningView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//

import SwiftUI

struct StopScanningView: View {
    @State private var showAlert = false
    @State private var showSeatView = true
    
    var body: some View {
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
                Text("Are you sure you want to stop scanning?")
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
        .transition(.move(edge: .top))
    }
}

#Preview {
    StopScanningView()
}
