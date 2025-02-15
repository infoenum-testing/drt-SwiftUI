//
//  LookupOrderResultView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//

import SwiftUI

struct LookupOrderResultView: View {
    let inputText: String
    var dismissAction: () -> Void
    @StateObject private var viewModel = LookupByOrderResultViewModel()
    @State private var orders: [Orders] = []
    @State private var seats: [SeatModel] = []
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
                        Text(order.buyerName?.uppercased() ?? "NO ORDER FOUND")
                            .foregroundColor(Color.customWhite)
                            .font(Font.custom("Verlag-Black", size: 25))
                            .padding(.trailing, 20)
                        Spacer()
                    }
                    HStack(alignment: .center) {
                        Text("ORDER \(order.orderId ?? 0)")
                            .font(Font.custom("Verlag-Bold", size: 15))
                            .foregroundColor(Color.customWhite)
                        Text("CC \(order.cc ?? "")")
                            .font(Font.custom("Verlag-Bold", size: 15))
                            .foregroundColor(Color.customWhite)
                    }
                }.padding([.bottom, .top])
                .background(Color.showCodeButton)
                .frame(maxWidth: .infinity)

                VStack {
                    if seats.isEmpty {
                        Text("Loading seat information...")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        List {
                            ForEach(seats, id: \.seat) { seat in
                                SeatCell(seat: seat)
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
            self.seats = viewModel.seatsModel
        }
    }
}
