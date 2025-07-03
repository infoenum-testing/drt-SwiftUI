//
//  SeatCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.

import SwiftUI
import CoreData
import IQAPIClient

struct SeatCell: View {
    @Binding var seat: SeatModel
    @State private var isScanned: Bool
    @State private var scannedTime: String?
    @State private var isLoading = false
    @AppStorage("isOfflineMode") private var isOffline: Bool = false
    @AppStorage("showCode") private var savedShowCode: String?
    @AppStorage("deviceScanCount") private var deviceScanCount: Int = 0
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var showAlert: Bool
    @ObservedObject var lookupByOrderResultViewModel:LookupByOrderResultViewModel
    @EnvironmentObject var stringManager: StringManager
    
    
    // MARK: - Init
    init(seat: Binding<SeatModel>, showAlert: Binding<Bool>, lookupByOrderResultViewModel: LookupByOrderResultViewModel) {
        self._seat = seat
        self._showAlert = showAlert
        self.lookupByOrderResultViewModel = lookupByOrderResultViewModel
        self._isScanned = State(initialValue: seat.wrappedValue.scannedTime != nil)

        if let scannedDate = seat.wrappedValue.scannedTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            self._scannedTime = State(initialValue: formatter.string(from: scannedDate))
        } else {
            self._scannedTime = State(initialValue: nil)
        }
    }
    
    // MARK: - View
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(isScanned ? String(format: StringConstants.LandingView.previouslyScannedAt, scannedTime ?? "") : stringManager.strings?.orderDetail.notYetScanned ?? StringConstants.LandingView.notYetScanned)
                        .font(.verlagBoldAdaptive(size: 18))
                        .foregroundColor(Color.customGreen)
                }
                HStack(alignment: .center) {
                    HStack(alignment: .bottom, spacing: 0) {
                        Text(stringManager.strings?.orderDetail.section ?? StringConstants.LandingView.sectionLabel)
                            .font(.verlagBoldAdaptive(size: 15))
                            .foregroundColor(Color.customGreen)
                            .padding(.bottom, UIDevice.current.userInterfaceIdiom == .pad ? 3.5 : 2)
                        Text("\(seat.section)")
                            .font(.verlagBoldAdaptive(size: 20))
                            .foregroundColor(Color.customGreen)
                    }
                    Spacer()
                    HStack(alignment: .bottom, spacing: 0) {
                        Text(stringManager.strings?.orderDetail.row ?? StringConstants.LandingView.rowLabel)
                            .font(.verlagBoldAdaptive(size: 15))
                            .foregroundColor(Color.customGreen)
                            .padding(.bottom, 1.adaptiveForIpad)
                        Text("\(seat.row)")
                            .font(.verlagBoldAdaptive(size: 20))
                            .foregroundColor(Color.customGreen)
                    }
                    Spacer()
                    HStack(alignment: .bottom, spacing: 0) {
                        Text(stringManager.strings?.orderDetail.seat ?? StringConstants.LandingView.seatLabel)
                            .font(.verlagBoldAdaptive(size: 15))
                            .foregroundColor(Color.customGreen)
                            .padding(.bottom, 1.adaptiveForIpad)
                        Text("\(seat.seat)")
                            .font(.verlagBoldAdaptive(size: 22))
                            .foregroundColor(Color.customGreen)
                    }
                    
                    Spacer()
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .scaleEffect(1.0)
                            .padding(10)
                    } else {
                        Image(isScanned ? StringConstants.DRTImages.greenCheckImage : StringConstants.DRTImages.scanNow)
                            .frame(width: 40.adaptiveForIpad, height: 40.adaptiveForIpad)
                            .onTapGesture {
                                updateSeatWithScannedQrCode()
                            }
                            .disabled(isScanned)
                            .opacity(isScanned ? 0.5 : 1.0)
                    }
                }
            }
            .background(Color.customWhite)
            .padding([.leading, .top, .trailing])
            .padding(.bottom, 5)
            .onAppear {
                loadScannedStatus(for: seat)
            }
            Divider()
        }.edgesIgnoringSafeArea(.leading)
    }
    
    /// Updates seat as scanned, saving locally or sending to API depending on mode
    private func updateSeatWithScannedQrCode() {
        guard !isScanned else { return }

        isLoading = true

        if isOffline {
            
            // Offline: simulate scan delay and save locally
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                let currentDate = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                scannedTime = formatter.string(from: currentDate)

                seat.scannedTime = currentDate
                isScanned = true
                isLoading = false
                saveScannedStatus(for: seat)
                incrementDeviceScanCount()
            }
        } else {
            
            // Online: send QR to API
            guard let qrCode = seat.qr?.seat else {
                print("QR code is nil")
                isLoading = false
                return
            }

            IQAPIClient.scanTicket(code: savedShowCode ?? "", qr: qrCode) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let jsonResponse):
                        if let valid = jsonResponse["valid"] as? Bool, !valid {
                            // Scan was rejected
                            lookupByOrderResultViewModel.errorMessage = jsonResponse["message"] as? String ?? "Unknown error"
                            showAlert = true
                        } else {
                            // Scan accepted
                            let currentDate = Date()
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            scannedTime = formatter.string(from: currentDate)

                            seat.scannedTime = currentDate
                            isScanned = true
//                            incrementDeviceScanCount()
                        }

                    case .failure(let error):
                        print("Error scanning ticket: \(error.localizedDescription)")
                    }

                    isLoading = false
                }
            }
        }
    }
    
    // MARK: - Core Data Save
    
    /// Saves the scanned time into Core Data for offline tracking
    private func saveScannedStatus(for seat: SeatModel) {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "section == %@ AND row == %@ AND seat == %@", seat.section, seat.row, seat.seat)
        
        do {
            let fetchedSeats = try viewContext.fetch(fetchRequest)
            let seatEntity = fetchedSeats.first ?? Seat(context: viewContext)
            
            seatEntity.section = seat.section
            seatEntity.row = seat.row
            seatEntity.seat = seat.seat
            seatEntity.date_scanned = seat.scannedTime
            seatEntity.locally_scanned += 1
            try viewContext.save()
        } catch {
            print("Error saving scanned status: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Load Scanned State
    
    /// Loads scan status either from Core Data (offline) or from server (online)
    private func loadScannedStatus(for seat: SeatModel) {
        if isOffline {
            loadScannedStatusOffline(for: seat)
        } else {
            loadScannedStatusOnline(for: seat) { success in
                if !success {
                    loadScannedStatusOffline(for: seat)
                }
            }
        }
    }
 
    func incrementDeviceScanCount() {
        deviceScanCount += 1
        // The @AppStorage property wrapper will automatically persist the updated value
    }

    /// Load scanned status from Core Data in offline mode
    private func loadScannedStatusOffline(for seat: SeatModel) {
        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "section == %@ AND row == %@ AND seat == %@", seat.section, seat.row, seat.seat)
        
        do {
            if let fetchedSeat = try viewContext.fetch(fetchRequest).first {
                if let savedDate = fetchedSeat.date_scanned {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    scannedTime = formatter.string(from: savedDate)
                    isScanned = true
                    self.seat.scannedTime = savedDate
                }
                else {
                    scannedTime = nil
                    isScanned = false
                }
            }
            
            let scanFetchRequest: NSFetchRequest<Scan> = Scan.fetchRequest()
            scanFetchRequest.predicate = NSPredicate(format: "qrCode == %@", seat.seat)
            
            if let fetchedScan = try viewContext.fetch(scanFetchRequest).first {

                if let scanTimestamp = fetchedScan.timeStamp {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    scannedTime = formatter.string(from: Date(timeIntervalSince1970: scanTimestamp.doubleValue))
                    isScanned = true
                }
            }
        } catch {
            print("Error loading scanned status: \(error.localizedDescription)")
        }
    }
    
    /// Placeholder for fetching scanned status from server
    private func loadScannedStatusOnline(for seat: SeatModel, completion: @escaping (Bool) -> Void) {
    }
}
