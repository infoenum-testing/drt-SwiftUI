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
    @EnvironmentObject var stringManager: StringManager
    @StateObject private var viewModel: ScanningStatsViewModel
    @AppStorage("deviceScanCount") private var deviceScanCount: Int = 0
    @AppStorage("isOfflineMode") private var isOffline: Bool = false
    
    init(isPresented: Binding<Bool>, context: NSManagedObjectContext) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: ScanningStatsViewModel(context: context))
    }
    
    var body: some View {
        let statsString = stringManager.strings.stats
        VStack(spacing: 15) {
            HStack {
                Spacer()
                Text(statsString.scanningStats)
                    .font(.verlagBoldAdaptive(size: 30))
                    .foregroundColor(Color.primaryText)
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
                        .padding(.bottom)
                }
            }
            .padding(.top,38)
            VStack {
                Spacer()
                if viewModel.isLoading {
                    ProgressView()
                        .tint(Color.neutralText)
                } else if let stats = viewModel.stats {
                    statsRow(title: statsString.totalSeats, value: stats.totalSeats)
                    statsRow(title: statsString.totalScannableSeats, value: stats.seatsScannable)
                    statsRow(title: statsString.totalScannedSeats, value: stats.seatsScannedTotal)
                    statsRow(title: statsString.ticketsScannedByDevice, value: isOffline ? deviceScanCount : stats.seatsScannedByDevice)
                } 
                Spacer()
            }
            .clipped()
            .frame(height: UIScreen.main.bounds.height * 0.22)
        }
        .padding(15)
        .background(Color.secondaryBg)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            Task {
                await viewModel.fetchStats()
                UserDefaults.standard.set(Date(), forKey: "lastSkinUpdate")
            }
        }
    }
    
    @ViewBuilder
    private func statsRow(title: String, value: Int?) -> some View {
        HStack {
            Text(title)
                .font(.verlagBoldAdaptive(size: 20))
                .foregroundColor(Color.primaryText)
            Spacer()
            Text(value.map { "\($0)" } ?? "N/A")
                .font(.verlagBoldAdaptive(size: 20))
                .foregroundColor(Color.primaryText)
        }
        .padding(.bottom)
    }
}
