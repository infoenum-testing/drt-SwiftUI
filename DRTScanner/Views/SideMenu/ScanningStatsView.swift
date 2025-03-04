//
//  ScanningStatsView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//


import SwiftUI
import CoreData

//struct ScanningStatsView: View {
//    @Binding var isPresented: Bool
//    @StateObject private var viewModel = ScanningStatsViewModel()
//    
//    var body: some View {
//        VStack(spacing: 5) {
//            HStack {
//                Spacer()
//                Text("Scanning Stats")
//                    .font(Font.custom("Verlag-Bold", size: 30))
//                    .foregroundColor(.customWhite)
//                    .frame(alignment: .center)
//                    .padding(.leading, 10)
//                Spacer()
//                Button(action: {
//                    withAnimation(.easeInOut(duration: 0.5)) {
//                        isPresented = false
//                    }
//                }) {
//                    Image("Popup_cross_btn")
//                        .padding([.bottom, .top])
//                }
//            }
//            HStack {
//                Text("Total Seats:")
//                    .font(Font.custom("Avenir-Light", size: 20))
//                    .foregroundColor(.customWhite)
//                Spacer()
//                Text(viewModel.stats?.totalSeats ?? 0)
//                    .font(Font.custom("Avenir-Light", size: 20))
//                    .foregroundColor(.customWhite)
//            }
//            HStack {
//                Text("Total Scannable Seats: ")
//                    .font(Font.custom("Avenir-Light", size: 20))
//                    .foregroundColor(.customWhite)
//                Spacer()
//                Text("576")
//                    .font(Font.custom("Avenir-Light", size: 20))
//                    .foregroundColor(.customWhite)
//            }
//            HStack {
//                Text("Total Scanned Seats: ")
//                    .font(Font.custom("Avenir-Light", size: 20))
//                    .foregroundColor(.customWhite)
//                Spacer()
//                Text("0")
//                    .font(Font.custom("Avenir-Light", size: 20))
//                    .foregroundColor(.customWhite)
//            }
//            HStack {
//                Text("Tickets Scanned by Device:")
//                    .font(Font.custom("Avenir-Light", size: 20))
//                    .foregroundColor(.customWhite)
//                Spacer()
//                Text("0")
//                    .font(Font.custom("Avenir-Light", size: 20))
//                    .foregroundColor(.customWhite)
//            }
//        }
//        .padding(20)
//        .background(.showCodeButton)
//    }
//}

struct ScanningStatsView: View {
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ScanningStatsViewModel
    
    init(isPresented: Binding<Bool>, context: NSManagedObjectContext) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: ScanningStatsViewModel(context: context))
    }
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Spacer()
                Text("Scanning Stats")
                    .font(Font.custom("Verlag-Bold", size: 30))
                    .foregroundColor(.customWhite)
                    .frame(alignment: .center)
                    .padding(.leading, 10)
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isPresented = false
                    }
                }) {
                    Image("Popup_cross_btn")
                        .padding([.bottom, .top])
                }
            }

            if let stats = viewModel.stats {
                statsRow(title: "Total Seats:", value: viewModel.stats?.totalSeats)
                statsRow(title: "Total Scannable Seats:", value: stats.seatsScannable)
                statsRow(title: "Total Scanned Seats:", value: stats.seatsScannedTotal)
                statsRow(title: "Tickets Scanned by Device:", value: stats.seatsScannedByDevice)
            }
            
        }
        .padding(20)
        .background(.showCodeButton)
        .onAppear {
            Task {
                await viewModel.fetchStats()
            }
        }
    }

    @ViewBuilder
    private func statsRow(title: String, value: Int?) -> some View {
        HStack {
            Text(title)
                .font(Font.custom("Avenir-Light", size: 20))
                .foregroundColor(.customWhite)
            Spacer()
            Text(value.map { "\($0)" } ?? "N/A")
                .font(Font.custom("Avenir-Light", size: 20))
                .foregroundColor(.customWhite)
        }
    }
}
