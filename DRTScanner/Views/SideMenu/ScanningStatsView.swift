//
//  ScanningStatsView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//


import SwiftUI
import CoreData

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
                    .font(.verlagBoldAdaptive(size: 30))
                    .foregroundColor(.customWhite)
                    .frame(alignment: .center)
                    .padding(.leading, 10)
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        isPresented = false
                    }
                }) {
                    Image(StringConstants.DRTImages.crossImage)
                        .resizable()
                        .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                        .background(Color.clear)
                        .contentShape(Rectangle())
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
        .background(Color.FFCE_62)
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
                .font(.verlagBoldAdaptive(size: 20))
                .foregroundColor(.customWhite)
            Spacer()
            Text(value.map { "\($0)" } ?? "N/A")
                .font(.verlagBoldAdaptive(size: 20))
                .foregroundColor(.customWhite)
        }
    }
}
