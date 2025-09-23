//
//  ScanningStatsView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//


import SwiftUI
import CoreData
import Shimmer

struct ScanningStatsView: View {
    @Binding var isPresented: Bool
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var stringManager: StringManager
    @StateObject private var viewModel: ScanningStatsViewModel
    @AppStorage("deviceScanCount") private var deviceScanCount: Int = 0
    @AppStorage("isOfflineMode") private var isOffline: Bool = false
    
    // For row animation
    @State private var showRows: Bool = false
    
    init(isPresented: Binding<Bool>, context: NSManagedObjectContext) {
        self._isPresented = isPresented
        self._viewModel = StateObject(wrappedValue: ScanningStatsViewModel(context: context))
    }
    
    var body: some View {
        let statsString = stringManager.strings.stats
        
        ZStack {
            AppBackGroundView(
                width: UIScreen.main.bounds.width,
                height: UIScreen.main.bounds.height * (UIDevice.isNonNotchIphone ? 0.40 : 0.35),
                shadow: true
            )
            
            VStack(spacing: 0) {
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
                            .contentShape(Rectangle())
                            .padding(.bottom)
                    }
                }
                
                Spacer()
                
                ZStack {
                    VStack(spacing: 10) {
                        statsRowShimer()
                        statsRowShimer()
                        statsRowShimer()
                        statsRowShimer()
                    }
                    .opacity(viewModel.isLoading ? 1 : 0) // fade shimmer in/out
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
                    
                    VStack(spacing: 10) {
                        statsRow(title: statsString.totalSeats, value: viewModel.stats?.totalSeats ?? 0 )
                        statsRow(title: statsString.totalScannableSeats, value: viewModel.stats?.seatsScannable ?? 0 )
                        statsRow(title: statsString.totalScannedSeats, value: viewModel.stats?.seatsScannedTotal ?? 0 )
                        statsRow(
                            title: statsString.ticketsScannedByDevice,
                            value: isOffline ? deviceScanCount : viewModel.stats?.seatsScannedByDevice ?? 0
                        )
                    }
                    .opacity(viewModel.isLoading ? 0 : 1) // fade stats in/out
                }
                .frame(height: UIScreen.main.bounds.height * 0.22)
                
                Spacer()
            }
            .padding([.horizontal, .bottom], 15)
            .padding(.top, UIDevice.isNonNotchIphone ? 20 : 50)
            .onAppear {
                Task {
                    // 0.2 second delay
                    if !isOffline {
                        viewModel.isLoading = true
                    }
                    try? await Task.sleep(nanoseconds: 200_000_000)
                    await viewModel.fetchStats()
                    UserDefaults.standard.set(Date(), forKey: "lastSkinUpdate")
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width,
               height: UIScreen.main.bounds.height * (UIDevice.isNonNotchIphone ? 0.40 : 0.35))
        .edgesIgnoringSafeArea(.all)
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
    
    @ViewBuilder
    private func statsRowShimer() -> some View {
        HStack {
            // Placeholder for title
            Capsule()
                .frame(width: 150.adaptiveForIpad, height: 20.adaptiveForIpad)
                .foregroundColor(Color.primaryText)
                .shimmering(
                    active: true,
                    gradient: Gradient(colors: [
                        Color.neutralText.opacity(0.3),
                        Color.neutralText,
                        Color.neutralText.opacity(0.3)
                    ])
                )
            
            Spacer()
            
            Capsule()
                .frame(width: 50.adaptiveForIpad, height: 20.adaptiveForIpad)
                .foregroundColor(Color.primaryText)
                .shimmering(
                    active: true,
                    gradient: Gradient(colors: [
                        Color.neutralText.opacity(0.3),
                        Color.neutralText,
                        Color.neutralText.opacity(0.3)
                    ])
                )
            
        }
        .padding(.bottom)
    }
}
