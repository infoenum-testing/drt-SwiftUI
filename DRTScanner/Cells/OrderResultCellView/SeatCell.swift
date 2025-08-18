//
//  SeatCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.

import SwiftUI
import CoreData
import IQAPIClient
import AVFoundation

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
    @State var audioPlayer: AVAudioPlayer?

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
            HStack {
            VStack(alignment: .leading) {
                HStack {
                    if isScanned {
                        if let scannTime = seat.tsScanned?.toDateFromMillisecondsTimestamp() {
                            CustomsText(title: getScanLabel(from: scannTime), textFont: .verlagBoldAdaptive(size: 18), foregroundColour: .primaryBg)
                        }
                    } else {
                        CustomsText(title: stringManager.strings.orderDetail.notYetScanned, textFont: .verlagBoldAdaptive(size: 18), foregroundColour: .primaryBg)
                    }
                }
                    HStack(alignment: .center) {
                        HStack(alignment: .bottom, spacing: 2) {
                            CustomsText(title: stringManager.strings.orderDetail.section, textFont: .verlagBoldAdaptive(size: 15), foregroundColour: .primaryBg)
                            
                            CustomsText(title: "\(seat.section)", textFont: .verlagBoldAdaptive(size: 20), foregroundColour: .primaryBg)
                          
                        }
                        Spacer()
                        HStack(alignment: .bottom, spacing: 2) {
                            CustomsText(title: stringManager.strings.orderDetail.row, textFont: .verlagBoldAdaptive(size: 15), foregroundColour: .primaryBg)
                                .padding(.bottom, 1.adaptiveForIpad)
                            
                            CustomsText(title: "\(seat.row)", textFont: .verlagBoldAdaptive(size: 20), foregroundColour: .primaryBg)
                        }
                        Spacer()
                        HStack(alignment: .bottom, spacing: 2) {
                            CustomsText(title: stringManager.strings.orderDetail.seat, textFont: .verlagBoldAdaptive(size: 15), foregroundColour: .primaryBg)
                            
                            CustomsText(title: seat.seat, textFont: .verlagBoldAdaptive(size: 22), foregroundColour: .primaryBg)
                        }
                    }
                }
                ZStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                            .scaleEffect(1.0)
                            .padding(10)
                            .frame(width: 50.adaptiveForIpad, height: 50.adaptiveForIpad)

                    } else {
                        Image(isScanned ? StringConstants.DRTImages.greenCheckImage : StringConstants.DRTImages.scanNow)
                            .frame(width: 50.adaptiveForIpad, height: 50.adaptiveForIpad)
                            .disabled(isScanned)
                            .opacity(isScanned ? 0.5 : 1.0)
                    }
                }
                .padding(.vertical)
                .frame(width:UIScreen.main.bounds.width*0.20)
                .background(Color.primaryText)
                .onTapGesture {
                    updateSeatWithScannedQrCode()
                }
            }
            .background(Color.primaryText)
            .padding([.leading, .top])
            .padding(.bottom, 5)
            .onAppear {
                loadScannedStatus(for: seat)
            }
            Divider()
        }
        .edgesIgnoringSafeArea(.leading)
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
                playScanFeedback(scannerResult: .valid)

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
                        if jsonResponse.valid {
                            // Scan was rejected
                          
                            let currentDate = Date()
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            scannedTime = formatter.string(from: currentDate)
                            
                            seat.scannedTime = currentDate
                            isScanned = true
                            //  incrementDeviceScanCount()
                            playScanFeedback(scannerResult: .valid)
                        } else {
                            // Scan accepted
                            lookupByOrderResultViewModel.errorMessage = jsonResponse.message
                            showAlert = true
                            playScanFeedback(scannerResult: .invalid)
                        }
                        
                    case .failure(let error):
                        print("Error scanning ticket: \(error.localizedDescription)")
                    }
                    
                    isLoading = false
                }
            }
        }
    }
    
    func playScanFeedback(scannerResult: ScannerResult) {
        if UserDefaults.standard.bool(forKey:"kShouldPlayHaptic") {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) // Haptic vibration
        }
        
        let shouldPlayBeep = UserDefaults.standard.bool(forKey: "kShouldPlayBeep")
        if !shouldPlayBeep {
            return
        }
       if scannerResult == .valid {
           if let soundURL = Bundle.main.url(forResource: "scan", withExtension: "wav") {
               do {
                   audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                   audioPlayer?.prepareToPlay()
                   audioPlayer?.play()
               } catch {
                   print("Error playing beep.mp3: \(error.localizedDescription)")
               }
           } else {
               print("beep.mp3 not found in bundle")
           }
       } else if scannerResult == .invalid || scannerResult == .previouslyScanned {
           if let soundURL = Bundle.main.url(forResource: "fail", withExtension: "wav") {
               do {
                   audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                   audioPlayer?.prepareToPlay()
                   audioPlayer?.play()
               } catch {
                   print("Error playing beep.mp3: \(error.localizedDescription)")
               }
           } else {
               print("beep.mp3 not found in bundle")
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
    
    
    func getScanLabel(from scanDate: Date) -> String {
        let now = Date()
        let diffSeconds = Int(now.timeIntervalSince(scanDate))
        let diffMinutes = diffSeconds / 60
        let diffHours = diffMinutes / 60
        let diffDays = diffHours / 24

        let labelTemplate =  stringManager.strings.orderDetail.previouslyScanned
        let labelscaned =  stringManager.strings.orderDetail.scanned

        switch diffMinutes {
        case ..<2:
            let lable =  String(format: labelscaned, "")
            return "\(lable)\n\(stringManager.strings.orderDetail.justNow)"
        case 2..<60:
            let timeLabel = String(format: stringManager.strings.orderDetail.minsAgo, "\(diffMinutes)")
            let lable = String(format: labelTemplate, "")
            return "\(lable)\n\(timeLabel)"
        case 60..<1440:
            let hourAgoString = diffHours == 1 ? stringManager.strings.orderDetail.hourAgo : stringManager.strings.orderDetail.hoursAgo
            let timeLabel = String(format: hourAgoString, "\(diffHours)")
            let lable = String(format: labelTemplate, "")
            return "\(lable)\n\(timeLabel)"
        case 1440..<2880:
            let lable = String(format: labelTemplate, "")
            return "\(lable)\n\(stringManager.strings.orderDetail.yesterday)"

        default:
            let timeLabel = String(format: stringManager.strings.orderDetail.daysAgo, "\(diffDays)")
            let lable = String(format: labelTemplate, "")
            return "\(lable)\n\(timeLabel)"
        }
    }
}
