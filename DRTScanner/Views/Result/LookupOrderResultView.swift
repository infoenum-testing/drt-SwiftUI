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
    @StateObject private var viewModel = LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext)
    @State private var orders: [Orders] = []
    @State private var seats: [SeatModel] = []
    let errorMessage: String?
    let order: Orders?

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
                        Text(order?.buyerName?.uppercased() ?? StringConstants.Common.noOrderFound)
                            .foregroundColor(Color.customWhite)
                            .font(Font.custom("Verlag-Black", size: 25))
                            .padding(.trailing, 20)
                        Spacer()
                    }
                    HStack(alignment: .center) {
                        Text("\(StringConstants.Common.Order) \(order?.orderId ?? 0)")
                            .font(Font.custom("Verlag-Bold", size: 15))
                            .foregroundColor(Color.customWhite)
                        Text("CC \(order?.cc ?? "")")
                            .font(Font.custom("Verlag-Bold", size: 15))
                            .foregroundColor(Color.customWhite)
                    }
                }.padding([.bottom, .top])
                .background(Color.showCodeButton)
                .frame(maxWidth: .infinity)

                VStack {
                    if seats.isEmpty {
                        Spacer()
                    } else {
                        List {
                            ForEach(seats.indices, id: \.self) { index in
                                SeatCell(seat: $seats[index])
                            }
                        }.listStyle(.plain)
                            .padding(0)
                    }
                }
            }
        }
            .background(Color.customWhite)
       // .ignoresSafeArea()
        .task {
            await viewModel.fetchSeats(c: StringConstants.Common.inputCode, q: inputText)
            self.orders = viewModel.orders
            if let seats = viewModel.seatsModel {
                self.seats = seats
            }
        }
    }
}
