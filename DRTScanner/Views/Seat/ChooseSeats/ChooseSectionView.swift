//
//  ChooseSectionView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//


import SwiftUI

struct ChooseSectionView: View {
    @State private var isLoading = false
    @State private var sectionsTitle: String = "SECTION"
    @Binding var isPresented: Bool
    @Binding var selectedSeat: String
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isPresented = false
                }) {
                    Image("left_side_arrow")
                }.padding()
                .frame(height: 85, alignment: .center)
                
            Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 20, height: 20)
                } else {
                    Text(sectionsTitle)
                        .font(.custom("Verlag-Black", size: 30))
                        .foregroundColor(.white)
                        .padding(.trailing, 50)
                }
                
                Spacer()
            }
            .background(Color.showCodeButton)
            VStack {
                ChooseSectionSubView(selectedSeat: $selectedSeat, isPresent: $isPresented)
            }
        }
        .background(Color.white)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isLoading = false
            }
        }
    }
}

struct ChooseSectionView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseSectionView(isPresented: .constant(true), selectedSeat: .constant(""))
    }
}
