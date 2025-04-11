//
//  ScannerView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/02/25.
//

import SwiftUI
import AVFoundation
import Vision
import IQAPIClient
import CoreData
import AudioToolbox

struct ScannerView: View {
    @Binding var seat: SeatModel?
    @State private var scannedCode: String?
    @State private var scanResult: String?
    @State private var isScanning = true
    @State private var flashLight: AVCaptureDevice?
    @State private var scanViewHeight: CGFloat = UIScreen.main.bounds.height / 3
    @State private var linePosition: CGFloat
    private let lineSpeed: CGFloat = 90.0
    @State private var timer: Timer?
    @State private var isScannerActive = true
    @State private var isCustomColorVisible = false
    @State private var isStopScanVisible = false
    @State private var scannerController: ScannerViewController?
    
    @State private var isScanned = false
    @State private var scannedTime: String?
    @State private var isLoading = false
    @AppStorage("showCode") private var savedShowCode: String?
    @AppStorage("isOfflineMode") private var isOffline: Bool = false
    @AppStorage("isMerchandise") private var isMerchandise: Bool?
    @AppStorage("kShowScanStats") private var showScanStats: Bool?
    @AppStorage("kShouldPlayBeep") private var shouldPlayBeep: Bool?
    @AppStorage("kPauseScanTimeout") var pauseScanTimeout: Int = 0
    @AppStorage("kAutoEnableFlashTimeout") private var autoEnableFlashTimeout: Bool = false
    @AppStorage("kAutoEnableFlashDelay") private var autoEnableFlashDelay: Int = 10
    @AppStorage("kDuplicateScanSuppression") private var duplicateScanSuppression: Int = 0
    @State private var lastScanTimes: [String: Date] = [:]
    @State private var suppressedOnce: Set<String> = []
    @State private var apiPreviouslyScannedQRCodes: Set<String> = []

    @State private var inactivityTimer: Timer?
    @State private var flashAutoOffTimer: Timer?
    @State private var flashAutoOnTimer: Timer?
    @Environment(\.managedObjectContext) private var viewContext
    @State private var shouldPlayBeepSound = false
    @State private var isOfflineMode = false
    @State private var isMerchandiseMode = false
    
    @State private var toastMessage: String?
    @State private var showToast = false
    
    @Binding var isTicketValid: Bool
    @Binding var isPreScanned: Bool
    @Binding var isInvalidTicket: Bool
    @Binding var orderName: String
    @Binding var orderNumber: String
    @Binding var orderDateScanned: String
    @Binding var isMerchTicketValid: Bool
    @Binding var isFullScreen: Bool
    //@State private var isFullScreen = false
    @State private var isMerchPreScanned = false
    @StateObject private var viewModel = ScanningStatsViewModel(context: PersistenceController.shared.container.viewContext)
    
    //animation
    @State var isVisibleText: Bool = false
    @State private var dragLocation: CGPoint = .zero
    @State private var isFlashOn = false
    let dragAreaSize: CGSize = CGSize(width: 80, height: 80)
    
    @Binding var isScanningCell: Bool
    @ObservedObject var scannerViewModel: ScannerViewModel
    
    @State private var isProcessingScan = false
    @State private var lastScannedCode: String?
    @State private var lastScannedTime: TimeInterval = 0
    
    init(seat: Binding<SeatModel?>,
         isTicketValid: Binding<Bool>,
         isPreScanned: Binding<Bool>,
         isInvalidTicket: Binding<Bool>,
         orderName: Binding<String>,
         orderNumber: Binding<String>,
         orderDateScanned: Binding<String>,
         isMerchTicketValid: Binding<Bool>,
         isFullScreen: Binding<Bool>,
         isScanningCell: Binding<Bool>,
         scannerViewModel: ScannerViewModel) {
        _linePosition = State(initialValue: 0)
        self._seat = seat
        _isTicketValid = isTicketValid
        _isPreScanned = isPreScanned
        _isInvalidTicket = isInvalidTicket
        _orderName = orderName
        _orderNumber = orderNumber
        _orderDateScanned = orderDateScanned
        _isMerchTicketValid = isMerchTicketValid
        _isFullScreen = isFullScreen
        _isScanningCell = isScanningCell
        self.scannerViewModel = scannerViewModel
    }
    
    var body: some View {
        VStack {
            ZStack {
                CameraScannerView(
                    onScan: { scanned in
                        scannedCode = scanned
                        sendScanRequest(qr: scanned)
                        resetInactivityTimer()
                    },
                    onControllerCreated: { controller in
                        DispatchQueue.main.async {
                            scannerController = controller
                            controller.isScanningBinding = $isScanningCell
                        }
                    },
                    isScanning: $isScanningCell
                ).padding(.bottom, -30)
                    .frame(height: isFullScreen ? nil : scanViewHeight)
                    .frame(maxWidth: .infinity)
                    .onChange(of: isScanning) { newValue in
                        if newValue {
                            scannerController?.startScanning()
                        } else {
                            scannerController?.stopScanning()
                        }
                    }
                if isFullScreen {
                    VStack {
                        Spacer()
                        if isTicketValid {
                            if isPreScanned {
                                PreviouslyScannedTicketView(orderName: orderName, orderNumber: orderNumber, scannedTime: orderDateScanned)
                            } else {
                                ValidTicketView(orderName: orderName, orderNumber: orderNumber)
                            }
                        } else if isInvalidTicket {
                            InvalidTicketView()
                        } else if isMerchandiseMode {
                            if isMerchPreScanned {
                                PreviousMerchandiseScanView()
                            }
                            if isMerchTicketValid {
                                MerchandiseScanView()
                            }
                        }
                        Spacer()
                    }.frame(height: isFullScreen ? UIScreen.main.bounds.height * 1 : scanViewHeight)
                        .onAppear {
                               startInactivityTimer()
                           }
                    AnyView(EmptyView())
                }
                VStack {
                    HStack {
                        Spacer()
                        HStack {
                            Image(isFlashOn ? "FlashOff" : "FlashOn")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding(.top, isFullScreen ? 30 : 0)
                                .padding()
                        }  .frame(width: dragAreaSize.width, height: dragAreaSize.height)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let location = value.location
                                        if isInsideBounds(location) {
                                            if !isFlashOn {
                                                isFlashOn = true
                                                toggleTorch(status: true)
                                            }
                                        } else {
                                            if isFlashOn {
                                                isFlashOn = false
                                                toggleTorch(status: false)
                                                flashAutoOffTimer?.invalidate()
                                            }
                                        }
                                        startFlashInactivityTimer()
                                    }
                                    .onEnded { _ in
                                        if isFlashOn {
                                            isFlashOn = false
                                            toggleTorch(status: false)
                                            flashAutoOffTimer?.invalidate()
                                        }
                                        startFlashInactivityTimer()
                                    }
                            )

                    }
                    
                    Spacer()
                    HStack {
                        if !isFullScreen {
                            Image("Scan_icon")
                                .frame(width: 50, height: 50)
                                .padding(.leading)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    DispatchQueue.main.async {
                                        stopScanner()
                                        isCustomColorVisible = true
                                    }
                                }
                        }
                        if showScanStats ?? false {
                            if let stats = viewModel.stats {
                                Spacer()
                                Text("Scanned by Device: \(stats.seatsScannedByDevice ?? 0) Scannable Overall: \( stats.seatsScannable ?? 0)")
                                    .font(Font.custom("Verlag-Book", size: 14))
                                    .padding(.bottom, 0)
                                    .foregroundColor(.white)
                                    .opacity(isVisibleText ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.3), value: isVisibleText)
                                
                                Spacer()
                            }
                        } else {
                            Spacer()
                        }
                        
                        Image(isFullScreen ? "video_Default_screen_icon" : "video_full_screen_icon")
                            .frame(width: 50, height: 50)
                        // .font(Font.custom("Verlag-Bold", size: 30))
                            .padding(.trailing)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    resetScanner()
                                    isFullScreen.toggle()
                                }
                            }
                    }.allowsHitTesting(true)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, isFullScreen ? 10 : -10)
                }.frame(maxHeight: isFullScreen ? .infinity : scanViewHeight, alignment: .bottom)
                
                if isCustomColorVisible && !isFullScreen {
                    Color.FDB_54_E
                        .opacity(1)
                        .frame(height: scanViewHeight + 30)
                        .overlay(
                            Image("scan__cirle_icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .onTapGesture {
                                    resetScanner()
                                }
                        )
                        .padding(.bottom, -30)
                }
                
                if isStopScanVisible && !isFullScreen {
                    Color.FFCE_62
                        .opacity(1)
                        .frame(height: scanViewHeight + 30)
                        .overlay(
                            Text("Scanning Pause")
                                .font(Font.custom("Verlag-Bold", size: 30))
                                .foregroundColor(.white)
                                .onTapGesture {
                                    resetScanner()
                                }
                        )
                        .padding(.bottom, -30)
                }
                
                if !isCustomColorVisible && !isAnyOverlayDisplayed && !isStopScanVisible {
                    Rectangle()
                        .frame(height: 1.5)
                        .foregroundColor(.red)
                        .shadow(color: .black, radius: 1.5)
                        .offset(y: linePosition - ((isFullScreen ? UIScreen.main.bounds.height : scanViewHeight) / 2))
                        .onAppear {
                            startLineAnimation()
                        }
                }
            }.onAppear {
                Task {
                    await viewModel.fetchStats()
                }
            }
            .onChange(of: scannerViewModel.shouldResetScanner) { _ in
                startInactivityTimer()
                isStopScanVisible = false
                startFlashInactivityTimer()
                
            }
        }
        .onAppear {
            setupScanner()
            startInactivityTimer()
            isOfflineMode = isOffline
            isMerchandiseMode = isMerchandise ?? false
            withAnimation {
                isVisibleText = true
            }
        }
        .onDisappear {
            stopLineAnimation()
            stopInactivityTimer()
            isOfflineMode = isOffline
            isMerchandiseMode = isMerchandise ?? false
        }
        
        .onChange(of: isOffline) { newValue in
            DispatchQueue.main.async {
                isOfflineMode = newValue
            }
        }
        .onChange(of: isMerchandise) { newValue in
            DispatchQueue.main.async {
                isMerchandiseMode = newValue ?? false
            }
        }
        .onChange(of: isFullScreen) { _ in
            stopLineAnimation()
            startLineAnimation()
        }
        .onChange(of: shouldPlayBeep) { newValue in
            DispatchQueue.main.async {
                shouldPlayBeepSound = newValue ?? false
            }
        }
        .onAppear {
            startFlashInactivityTimer()
        }
        .onDisappear {
            stopFlashInactivityTimer()
        }

    }
    
    private func startFlashInactivityTimer() {
        flashAutoOnTimer?.invalidate()

        guard autoEnableFlashTimeout else { return }

        flashAutoOnTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(autoEnableFlashDelay), repeats: false) { _ in
            if let scanner = scannerController, scanner.captureSession?.isRunning == true {
                if !isFlashOn {
                    isFlashOn = true
                    toggleTorch(status: true)
                    startFlashAutoOffTimer()
                }
            } else {
                print("🔁 Skipping flash-on: Scanner is not running")
            }
        }
    }

    private func startFlashAutoOffTimer() {
        flashAutoOffTimer?.invalidate()

        flashAutoOffTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            if isFlashOn {
                isFlashOn = false
                toggleTorch(status: false)
            }

            if let scanner = scannerController, scanner.captureSession?.isRunning == true {
                startFlashInactivityTimer()
            } else {
                print("⏹️ Flash auto-off: Scanner not running, not restarting timer")
            }
        }
    }


    private func stopFlashInactivityTimer() {
        flashAutoOnTimer?.invalidate()
        flashAutoOffTimer?.invalidate()
    }

    private func resetFlashInactivityTimer() {
        startFlashInactivityTimer()
    }
    
    private func setupScanner() {
        flashLight = AVCaptureDevice.default(for: .video)
    }
    
    private func startLineAnimation() {
        let animationHeight = isFullScreen ? UIScreen.main.bounds.height * 1 : scanViewHeight
        if isFullScreen {
            linePosition = 0
        }
        withAnimation(Animation.linear(duration: Double(animationHeight / lineSpeed)).repeatForever(autoreverses: true)) {
            linePosition = animationHeight
        }
    }
    
    private func stopLineAnimation() {
        linePosition = 0
    }
    
    private var isAnyOverlayDisplayed: Bool {
        return (isFullScreen && (isTicketValid || isInvalidTicket || isMerchTicketValid || isPreScanned || isMerchPreScanned))
    }
    
    private func resetScanner() {
        isCustomColorVisible = false
        isStopScanVisible = false
        scannedCode = nil
        scanResult = nil
        isScanning = true
        isScannerActive = true
        isScanningCell = true
        linePosition = 0
        startLineAnimation()
        startInactivityTimer()
        startFlashInactivityTimer()
    }
    
    private func startInactivityTimer() {
        timer?.invalidate()
        
        guard pauseScanTimeout > 0 else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(pauseScanTimeout), repeats: false) { _ in
            if !isFullScreen {
                isScanningCell = false
                self.activateColorOverlay()
                stopLineAnimation()
                self.scannerController?.stopScanning()
                if isFlashOn {
                    isFlashOn = false
                    toggleTorch(status: false)
                }
                stopFlashInactivityTimer()
            }
        }
    }
    
    private func stopInactivityTimer() {
        timer?.invalidate()
    }
    
    private func resetInactivityTimer() {
        startInactivityTimer()
    }
    
    private func stopScanner() {
        isScannerActive = false
        scannerController?.captureSession?.stopRunning()
        scannerController = nil
    }
    
    private func activateColorOverlay() {
        isStopScanVisible = true
    }
    
    private func toggleTorch(status: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            device.torchMode = status ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used: \(error.localizedDescription)")
        }
    }
    
    private func isInsideBounds(_ location: CGPoint) -> Bool {
        return location.x >= 0 &&
        location.y >= 0 &&
        location.x <= dragAreaSize.width &&
        location.y <= dragAreaSize.height
    }
    
    private func sendScanRequest(qr: String) {
        let cleanedQR = qr
            .replacingOccurrences(of: "{\"seat\":[", with: "")
            .replacingOccurrences(of: "{\"merch\":[", with: "")
            .replacingOccurrences(of: "]}", with: "")
            .replacingOccurrences(of: "\"", with: "")
        
        let qrCodes = cleanedQR.components(separatedBy: ",").filter { !$0.isEmpty }
        let isMerch = isMerchandise ?? false
        let scanType = isMerch ? "merch" : "seat"
        guard let qrCode = qrCodes.first else { return }
        
        let now = Date()
        let suppressionSeconds = duplicateScanSuppression
        
        if suppressionSeconds > 0,
           let lastScan = lastScanTimes[cleanedQR] {
            let timeSinceLast = now.timeIntervalSince(lastScan)
            
            if timeSinceLast < Double(suppressionSeconds) {
                if !suppressedOnce.contains(cleanedQR) {
                    suppressedOnce.insert(cleanedQR)
                    lastScanTimes[cleanedQR] = now
                    
                    isTicketValid = true
                    if shouldPlayBeepSound {
                        AudioServicesPlaySystemSound(1022)
                    }
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isTicketValid = false
                        }
                    }
                    isScanning = false
                    return
                }
            } else {
                suppressedOnce.remove(cleanedQR)
            }
        }
        
        if isOfflineMode {
            let separatedQRCodes = qrCodes.joined(separator: "-")
            
            if isMerchandiseMode {
                let qrCodesArray = separatedQRCodes.components(separatedBy: "-")
                let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "qrCode IN %@", qrCodesArray)
                
                do {
                    let results = try viewContext.fetch(fetchRequest)
                    if let order = results.first {
                        if let scannedTime = order.date_scanned {
                            showToastMessage("This merchandise was already scanned at \(scannedTime).")
                        } else {
                            order.date_scanned = Date()
                            try viewContext.save()
                            isMerchTicketValid = true
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isMerchTicketValid = false
                                }
                            }
                        }
                    } else {
                        isInvalidTicket = true
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isInvalidTicket = false
                            }
                        }
                    }
                } catch {
                    showToastMessage("Database error: \(error.localizedDescription)")
                }
            } else {
                let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "qrCode == %@", separatedQRCodes)
                
                do {
                    let results = try viewContext.fetch(fetchRequest)
                    if let seatEntity = results.first {
                        if let scannedTime = seatEntity.date_scanned {
                            isPreScanned = true
                            isTicketValid = true
                            orderName = seatEntity.order?.buyer_name ?? "Unknown"
                            orderNumber = seatEntity.order_id.map(String.init) ?? "N/A"
                            orderDateScanned = scannedTime.formatted(date: .omitted, time: .shortened)
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isPreScanned = false
                                    isTicketValid = false
                                }
                            }
                        } else {
                            seatEntity.date_scanned = Date()
                            try viewContext.save()
                            isTicketValid = true
                            orderName = seatEntity.order?.buyer_name ?? "Unknown"
                            orderNumber = seatEntity.order_id.map(String.init) ?? "N/A"
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isTicketValid = false
                                }
                            }
                            lastScanTimes[cleanedQR] = now
                            suppressedOnce.remove(cleanedQR)
                        }
                    } else {
                        isInvalidTicket = true
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isInvalidTicket = false
                            }
                        }
                    }
                } catch {
                    showToastMessage("Database error: \(error.localizedDescription)")
                }
            }
            
            if qr.allSatisfy({ $0.isNumber }) {
                let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "barcode == %@", qr)
                
                do {
                    let results = try viewContext.fetch(fetchRequest)
                    if let seatEntity = results.first {
                        if let scannedTime = seatEntity.date_scanned {
                            isPreScanned = true
                            isTicketValid = true
                            orderName = seatEntity.order?.buyer_name ?? "Unknown"
                            orderNumber = seatEntity.order_id.map(String.init) ?? "N/A"
                            orderDateScanned = scannedTime.formatted(date: .omitted, time: .shortened)
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isPreScanned = false
                                    isTicketValid = false
                                }
                            }
                        } else {
                            seatEntity.date_scanned = Date()
                            try viewContext.save()
                            isTicketValid = true
                            orderName = seatEntity.order?.buyer_name ?? "Unknown"
                            orderNumber = seatEntity.order_id.map(String.init) ?? "N/A"
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isTicketValid = false
                                }
                            }
                            lastScanTimes[cleanedQR] = now
                            suppressedOnce.remove(cleanedQR)
                        }
                    } else {
                        isInvalidTicket = true
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isInvalidTicket = false
                            }
                        }
                    }
                } catch {
                    isInvalidTicket = true
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isInvalidTicket = false
                        }
                    }
                }
            }
        } else {
            if qr.allSatisfy({ $0.isNumber }) {
                IQAPIClient.scanTicketBarcode(code: savedShowCode ?? "", barcode: qr) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let responseData):
                            if let responseDict = responseData as? [String: Any], let message = responseDict["message"] as? String {
                                if message == "Previously Scanned" {
                                    if let scannedTime = responseDict["date_scanned"] as? String {
                                        isPreScanned = true
                                        isTicketValid = true
                                        orderName = (responseDict["buyer_name"] as? String)?.capitalized ?? "Unknown"
                                        orderNumber = String(responseDict["oid"] as? Int ?? 3333876)
                                        orderDateScanned = responseDict["date_scanned"] as? String ?? ""
                                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                isPreScanned = false
                                                isTicketValid = false
                                            }
                                        }
                                    } else {
                                        showToastMessage("This ticket has been previously scanned.")
                                    }
                                } else {
                                    isTicketValid = true
                                    orderName = (responseDict["buyer_name"] as? String)?.capitalized ?? "Unknown"
                                    orderNumber = String(responseDict["oid"] as? Int ?? 0)
                                    orderDateScanned = responseDict["date_scanned"] as? String ?? ""
                                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            isTicketValid = false
                                        }
                                    }
                                    lastScanTimes[cleanedQR] = now
                                    suppressedOnce.remove(cleanedQR)
                                }
                            }
                        case .failure(_):
                            isInvalidTicket = true
                            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isInvalidTicket = false
                                }
                            }
                        }
                    }
                }
            } else {
                if isMerchandiseMode {
                    IQAPIClient.scanProductQrCode(code: savedShowCode ?? "", qr: qrCodes) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let responseData):
                                if let responseDict = responseData as? [String: Any], let message = responseDict["message"] as? String {
                                    if message == "Previously Scanned" {
                                        if let scannedTime = responseDict["date_scanned"] as? String {
                                            showToastMessage("This merchandise was previously scanned at \(scannedTime).")
                                        } else {
                                            showToastMessage("This merchandise has been previously scanned.")
                                        }
                                    } else {
                                        isMerchTicketValid = true
                                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            withAnimation {
                                                isMerchTicketValid = false
                                            }
                                        }
                                    }
                                }
                            case .failure(let error):
                                showToastMessage("Error: \(error.localizedDescription)")
                            }
                        }
                    }
                } else {
                    IQAPIClient.scanTicketQrCode(code: savedShowCode ?? "36060-5E56", type: scanType, qr: qrCodes) { result in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let responseData):
                                if let responseDict = responseData as? [String: Any] {
                                    do {
                                        let jsonData = try JSONSerialization.data(withJSONObject: responseDict, options: [])
                                        let decoder = JSONDecoder()
                                        
                                        if let scanResponse = try? decoder.decode(ScanResponse.self, from: jsonData) {
                                            if scanResponse.valid {
                                                
                                                isTicketValid = true
                                                orderName = scanResponse.buyerName ?? "Unknown"
                                                orderNumber = String(scanResponse.oid ?? 0)
                                                if shouldPlayBeepSound {
                                                    AudioServicesPlaySystemSound(1022)
                                                }
                                                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    withAnimation {
                                                        isTicketValid = false
                                                    }
                                                }
                                                
                                                seat?.scannedTime = Date()
                                                isScanning = false
                                                lastScanTimes[cleanedQR] = now
                                                suppressedOnce.remove(cleanedQR)
                                            } else if scanResponse.message == "Previously Scanned" {
                                                isPreScanned = true
                                                isTicketValid = true
                                                orderName = scanResponse.buyerName ?? "Unknown"
                                                orderNumber = String(scanResponse.oid ?? 3333876)
                                                orderDateScanned = scanResponse.dateScanned ?? ""
                                                if shouldPlayBeepSound {
                                                    AudioServicesPlaySystemSound(1022)
                                                }
                                                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    withAnimation {
                                                        isPreScanned = false
                                                        isTicketValid = false
                                                    }
                                                }
                                                isScanning = false
                                                
                                            } else {
                                                isInvalidTicket = true
                                                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    withAnimation { isInvalidTicket = false }
                                                }
                                                isScanning = false
                                            }
                                            
                                        } else {
                                            showToastMessage("Invalid response format.")
                                            isScanning = false
                                        }
                                        
                                    } catch {
                                        showToastMessage("Failed to decode response: \(error.localizedDescription)")
                                        isScanning = false
                                    }
                                } else {
                                    showToastMessage("Error: Invalid response format.")
                                    isScanning = false
                                }
                                
                            case .failure(_):
                                isInvalidTicket = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    withAnimation { isInvalidTicket = false }
                                }
                                isScanning = false
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
}

@ViewBuilder
func statsRow(title: String, value: Int) -> some View {
    HStack {
        Text(title)
            .font(.headline)
        Spacer()
        Text("\(value)")
            .font(.title3)
            .bold()
    }
    .padding()
}
