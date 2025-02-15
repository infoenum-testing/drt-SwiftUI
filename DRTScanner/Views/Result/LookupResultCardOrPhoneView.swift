//
//  LookupResultCardOrPhoneView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI

struct LookupResultCardOrPhoneView: View {
    let inputText: String
    var dismissAction: () -> Void
    @StateObject private var viewModel = LookupByCreditCardResultViewModel()
    @State private var orders: [Orders] = []
  // let orderModel: OrderModel
    let errorMessage: String?
    let order: Orders

    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                VStack {
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dismissAction()
                            }
                        }) {
                            Image("left_side_arrow")
                        }
                        .padding(.leading, 20)
                        
                        Spacer()
                        
                        Text(errorMessage)
                            .foregroundColor(Color.customWhite)
                            .font(Font.custom("Verlag-Bold", size: 30))
                            .padding(.trailing, 20)
                        
                        Spacer()
                    }
                }.padding()
                .background(Color.showCodeButton)
                .frame(maxWidth: .infinity)
            } else {
                VStack {
                    HStack (alignment: .center){
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                dismissAction()
                            }
                        }) {
                            Image("left_side_arrow")
                        }.padding(.leading, 20)
                        
                        Spacer()
                        Text("Total Results:")
                            .foregroundColor(Color.customWhite)
                            .font(Font.custom("Verlag-Black", size: 25))
                            .padding(.trailing, 20)
                        Spacer()
                    }
                }.padding([.bottom, .top])
                .background(Color.showCodeButton)
                .frame(maxWidth: .infinity)

                VStack {
                    if orders.isEmpty {
                        Text("Loading Order information...")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(orders, id: \.orderId) { seat in
                                LookupCellView(result: seat)
                            }
                        }.listStyle(.plain)
                        .padding(0)
                    }
                }
            }
        }.frame(maxHeight: .infinity)
            .background(Color.customWhite)
        .ignoresSafeArea()
        .task {
            await viewModel.fetchSeats(c: "289-6385", q: inputText)
            self.orders = viewModel.orders
            print("Seat")
           // self.orders = viewModel.seatsModel
        }
    }
}

struct LookupCellView: View {
    var result: Orders
    
    var body: some View {
        VStack(alignment: .center) {
            Text(result.buyerName ?? "")
                .font(.custom("Verlag-Black", size: 24))
                .foregroundColor(Color.showCodeText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)

            HStack(alignment: .center) {
                Text("ORDER: \(result.orderId)")
                    .font(.custom("Verlag-Bold", size: 22))
                    .foregroundColor(Color.showCodeText)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("CC: \(result.cc)")
                    .font(.custom("Verlag-Bold", size: 22))
                    .foregroundColor(Color.showCodeText)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top, 5)

            Text("PHONE NUMBER: \(result.phone ?? "")")
                .font(.custom("Verlag-Bold", size: 22))
                .foregroundColor(Color.showCodeText)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 10)
        }
        .padding(10)
    }
}
//
//struct LookupResult: Identifiable {
//    let id = UUID()
//    let name: String
//    let order: String
//    let creditCard: String
//}

//struct LookupResultView_Previews: PreviewProvider {
//    static var previews: some View {
//        LookupResultCardOrPhoneView(dismissAction: {
//            print("Dismiss action triggered")
//        })
//    }
//}
