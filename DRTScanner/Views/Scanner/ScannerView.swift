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
    @AppStorage("kShouldPlayHaptic") var shouldPlayHaptic: Bool?
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
    @State private var shouldPlayHapticNew = false
    @State private var duplicateScanSuppressionNew = 0
    
    @State private var toastMessage: String?
    @State private var showToast = false
    
    @Binding var isTicketValid: Bool
    @Binding var isPreScanned: Bool
    @Binding var isInvalidTicket: Bool
    @Binding var isInvalidSeatTicket: Bool
    @Binding var isInvalidMerchTicket: Bool
    
    @Binding var orderName: String
    @Binding var orderNumber: String
    @Binding var orderDateScanned: String
    @Binding var isGoldenTicket: Bool
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
    
    @State private var scannerViewExpanded = false
    @State private var isUtilizingExternalBarcode = false
    @State private var showExternalBarcodeView = false
    @FocusState private var isExternalInputFocused: Bool
    @StateObject private var keyboardObserver = KeyboardObserver()
    @ObservedObject var lookupByOrderResultViewModel: LookupByOrderResultViewModel
    @Binding var showOfflineAlert: Bool
    
    @State private var isInputActive: Bool = false
    @State private var scannedExternalCode: String = ""
    @State private var audioPlayer: AVAudioPlayer?
    
    
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
         isGoldenTicket: Binding<Bool>,
         isInvalidSeatTicket: Binding<Bool>,
         isInvalidMerchTicket: Binding<Bool>,
         scannerViewModel: ScannerViewModel,
         lookupByOrderResultViewModel: LookupByOrderResultViewModel,
         showOfflineAlert: Binding<Bool>) {
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
        _isGoldenTicket = isGoldenTicket
        _isInvalidSeatTicket = isInvalidSeatTicket
        _isInvalidMerchTicket = isInvalidMerchTicket
        self.scannerViewModel = scannerViewModel
        self.lookupByOrderResultViewModel = lookupByOrderResultViewModel
        _showOfflineAlert = showOfflineAlert
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
                    .frame(height: isFullScreen ? nil : scanViewHeight.adaptiveForIpadScan)
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
                                ValidTicketView(orderName: orderName, orderNumber: orderNumber, isGoldenTicket: isGoldenTicket)
                            }
                        } else if isInvalidTicket {
                            InvalidTicketView()
                        } /*else if isMerchandiseMode {*/
                        if isMerchPreScanned {
                            PreviousMerchandiseScanView()
                        }
                        if isMerchTicketValid {
                            MerchandiseScanView()
                        }
                        if isInvalidMerchTicket {
                            InvalidMerchandiseTicketView()
                        }
                        
                        if isInvalidSeatTicket {
                            InvalidSeatTicketView()
                        }
                        //                        }
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
                                .frame(width: 50.adaptiveForIpad, height: 50.adaptiveForIpad)
                                .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? 10 : -10)
                                .padding(.top, isFullScreen ? 60 : (UIDevice.current.userInterfaceIdiom == .pad ? 60 : 0))
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
                                        startInactivityTimer()
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
                    
                    // external scanner
                    HStack {
                        if !isFullScreen {
                            Image("Scan_icon")
                                .resizable()
                               // .scaleEffect(x: -1, y: 1)
                                .frame(width: 30.adaptiveForIpad, height: 30.adaptiveForIpad)
                                .background(Color.clear)
                                .padding([.leading, .top])
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    DispatchQueue.main.async {
                                        externalScannerAction()
                                        isCustomColorVisible = true
                                        isInputActive = true
                                    }
                                }
                        }
                        if showScanStats ?? false {
                            if let stats = viewModel.stats {
                                Spacer()
                                Text("Scanned by Device: \(stats.seatsScannedByDevice ?? 0) Scannable Overall: \( stats.seatsScannable ?? 0)")
                                    .font(.verlagBookAdaptive(size: 16))
                                    .padding(.bottom, -30)
                                    .foregroundColor(.white)
                                    .opacity(isVisibleText ? 1 : 0)
                                    .animation(.easeInOut(duration: 0.3), value: isVisibleText)
                                
                                Spacer()
                            }
                        } else {
                            Spacer()
                        }
                        
                        Image(isFullScreen ? "video_Default_screen_icon" : "video_full_screen_icon")
                            .resizable()
                            .frame(width: 30.adaptiveForIpad, height: 30.adaptiveForIpad)
                            .background(Color.clear)
                            .padding([.top, .trailing])
                            .contentShape(Rectangle())
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                            .onTapGesture {
                                withAnimation {
                                    resetScanner()
                                    isFullScreen.toggle()
                                }
                            }
                    }.allowsHitTesting(true)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, isFullScreen ? 20 : 10)
                }.frame(maxHeight: isFullScreen ? .infinity : scanViewHeight, alignment: .bottom)
                
                if isCustomColorVisible && !isFullScreen {
                    ZStack {
                        ExternalBarcodeInputField(scannedCode: $scannedExternalCode, isActive: $isInputActive)
                            .frame(width: 200, height: 50)
                            .opacity(0.01)
                            .allowsHitTesting(true)
                        TextField("Enter barcode manually", text: $scannedExternalCode)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 250, height: 50)
                            .onChange(of: scannedExternalCode) { newValue in
                                print("Manual input: \(newValue)")
                            }
                        
                        Color.FFCE_62
                            .opacity(1)
                            .frame(height: scanViewHeight + 30.adaptiveForIpad)
                            .frame(height: 50.adaptiveForIpad)
                            .overlay(
                                VStack(spacing: 12) {
                                    Image("scan__cirle_icon")
                                        .resizable()
                                      //  .scaleEffect(x: -1, y: 1)
                                        .scaledToFit()
                                        .frame(width: 100.adaptiveForIpad, height: 100.adaptiveForIpad)
                                        .onTapGesture {
                                            resetScanner()
                                        }
                                }
                            )
                            .padding(.bottom, -30)
                    }
                    .onChange(of: scannedExternalCode) { newCode in
                        print("New barcode code received: \(newCode)")
                        if !newCode.isEmpty {
                            sendScanRequest(qr: newCode)
                            scannedExternalCode = ""
                        }
                    }
                }
                
                if isStopScanVisible && !isFullScreen && !isCustomColorVisible {
                    Color.FFCE_62
                        .opacity(1)
                        .frame(height: scanViewHeight + 30.adaptiveForIpad)
                        .frame(height: 50.adaptiveForIpad)
                        .overlay(
                            Text("Pause, click to resume")
                                .font(.verlagBoldAdaptive(size: 20))
                                .foregroundColor(.white)
                                .onTapGesture {
                                    resetScanner()
                                }
                        ).onTapGesture {
                            resetScanner()
                        }
                        .padding(.bottom, -30)
                }
                
                if !isCustomColorVisible && !isAnyOverlayDisplayed && !isStopScanVisible {
                    Rectangle()
                        .frame(height: 1.5)
                        .foregroundColor(.red)
                        .shadow(color: .black, radius: 1.5)
                        .offset(y: linePosition - ((isFullScreen ? UIScreen.main.bounds.height : scanViewHeight.adaptiveForIpadScan) / 2))
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
                isCustomColorVisible = false
                
                startFlashInactivityTimer()
            }
        }
        .onAppear {
            setupScanner()
            startInactivityTimer()
            isOfflineMode = isOffline
            isMerchandiseMode = isMerchandise ?? false
            shouldPlayHapticNew = shouldPlayHaptic ?? false
            shouldPlayBeepSound = shouldPlayBeep ?? false
            duplicateScanSuppressionNew = duplicateScanSuppression
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
        .onChange(of: keyboardObserver.isKeyboardVisible) { isVisible in
            if isVisible {
                stopLineAnimation()
            } else {
                startLineAnimation()
            }
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
        .onChange(of: shouldPlayHaptic) { newValue in
            DispatchQueue.main.async {
                shouldPlayHapticNew = newValue ?? false
            }
        }
        .onChange(of: duplicateScanSuppression) { newValue in
            DispatchQueue.main.async {
                duplicateScanSuppressionNew = newValue
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
                    DispatchQueue.main.async {
                        isFlashOn = true
                        toggleTorch(status: true)
                        startFlashAutoOffTimer()
                    }
                }
            } else {
                print("🔁 Skipping flash-on: Scanner is not running")
            }
        }
    }
    
    private func startFlashAutoOffTimer() {
        flashAutoOffTimer?.invalidate()
        
        flashAutoOffTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            DispatchQueue.main.async {
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
        return (isFullScreen && (isTicketValid || isInvalidTicket || isMerchTicketValid || isPreScanned || isMerchPreScanned || isInvalidSeatTicket || isInvalidMerchTicket))
    }
    
    private func resetScanner() {
        DispatchQueue.global(qos: .userInitiated).async {
            scannerController?.captureSession?.startRunning()
        }
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
    
    func externalScannerAction() {
        
        isUtilizingExternalBarcode = true
        isExternalInputFocused = true
        stopScanner()
        
        withAnimation(.easeInOut(duration: 0.2)) {
            showExternalBarcodeView = true
        }
    }
    
    
    private func isInsideBounds(_ location: CGPoint) -> Bool {
        return location.x >= 0 &&
        location.y >= 0 &&
        location.x <= dragAreaSize.width &&
        location.y <= dragAreaSize.height
    }
    
    private func sendScanRequest(qr: String) {
        //        let cleanedQR = qr
        //            .replacingOccurrences(of: "{\"seat\":[", with: "")
        //            .replacingOccurrences(of: "{\"merch\":[", with: "")
        //            .replacingOccurrences(of: "]}", with: "")
        //            .replacingOccurrences(of: "\"", with: "")
        
        var scanType = ""
        var cleanedQR = ""
        if qr.allSatisfy({ $0.isNumber }) {
            scanType = "barcode"
            cleanedQR = qr
        }
        // Handle seat QR code
        else if qr.contains("{\"seat\":[") {
            scanType = "seat"
            cleanedQR = qr
                .replacingOccurrences(of: "{\"seat\":[", with: "")
                .replacingOccurrences(of: "]}", with: "")
                .replacingOccurrences(of: "\"", with: "")
        } else if qr.contains("{\"merch\":[") {
            scanType = "merch"
            cleanedQR = qr
                .replacingOccurrences(of: "{\"merch\":[", with: "")
                .replacingOccurrences(of: "]}", with: "")
                .replacingOccurrences(of: "\"", with: "")
        }
        
        let qrCodes = cleanedQR.components(separatedBy: ",").filter { !$0.isEmpty }
        let isMerch = isMerchandise ?? false
        // let scanType = isMerch ? "merch" : "seat"
        guard let qrCode = qrCodes.first else { return }
        
        //        let now = Date()
        //        let suppressionSeconds = Double(duplicateScanSuppression)
        //
        //        let beforeCleanup = lastScanTimes.count
        //         lastScanTimes = lastScanTimes.filter { now.timeIntervalSince($0.value) < suppressionSeconds }
        //         suppressedOnce = suppressedOnce.filter { lastScanTimes[$0] != nil }
        //         print("🧹 Cleaned up old QR entries. Before: \(beforeCleanup), After: \(lastScanTimes.count)")
        //
        //         if suppressionSeconds > 0,
        //            let lastScan = lastScanTimes[cleanedQR] {
        //             let timeSinceLast = now.timeIntervalSince(lastScan)
        //             print("⏱️ QR '\(cleanedQR)' was last scanned \(timeSinceLast) seconds ago")
        //
        //             if timeSinceLast < suppressionSeconds {
        //                 if !suppressedOnce.contains(cleanedQR) {
        //                     print("⚠️ Duplicate scan suppressed for: \(cleanedQR)")
        //                     suppressedOnce.insert(cleanedQR)
        //                     lastScanTimes[cleanedQR] = now
        //
        //                     isTicketValid = true
        //                     playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
        //                     DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        //                         withAnimation { isTicketValid = false }
        //                     }
        //                     isScanning = false
        //                     return
        //                 }
        //             } else {
        //                 print("✅ Suppression window expired for: \(cleanedQR)")
        //                 suppressedOnce.remove(cleanedQR)
        //             }
        //         } else {
        //             print("🆕 First time scanning QR: \(cleanedQR)")
        //         }
        //
        //         print("📡 Sending scan request for QR: \(cleanedQR), Type: \(scanType)")
        
        let now = Date()
        let suppressionSeconds = Double(duplicateScanSuppressionNew)
        
        let beforeCleanup = lastScanTimes.count
        lastScanTimes = lastScanTimes.filter { now.timeIntervalSince($0.value) < suppressionSeconds }
        print("🧹 Cleaned up old QR entries. Before: \(beforeCleanup), After: \(lastScanTimes.count)")
        
        if suppressionSeconds > 0,
           let lastScan = lastScanTimes[cleanedQR] {
            
            let timeSinceLast = now.timeIntervalSince(lastScan)
            print("⏱️ QR '\(cleanedQR)' was last scanned \(timeSinceLast) seconds ago")
            
            if timeSinceLast < suppressionSeconds {
                print("⚠️ Duplicate scan suppressed for: \(cleanedQR)")
                return
            } else {
                print("✅ Suppression window expired for: \(cleanedQR)")
            }
        }
        
        lastScanTimes[cleanedQR] = now
        
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
                            playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isMerchTicketValid = false
                                }
                            }
                        }
                    } else {
                        isInvalidTicket = true
                        playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
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
                            playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
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
                            playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
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
                        playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
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
            
            if scanType == "barcode" {
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
                            playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
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
                            playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
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
                        playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isInvalidTicket = false
                            }
                        }
                    }
                } catch {
                    isInvalidTicket = true
                    playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
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
                                        
                                        playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
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
                                    isGoldenTicket = (responseDict["is_golden_ticket"] == nil)
                                    playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
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
                            playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
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
                    if scanType == "merch" {
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
                                            playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
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
                    }  else {
                        isInvalidMerchTicket = true
                        playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isInvalidMerchTicket = false
                            }
                        }
                        isScanning = false
                    }
                }
                else {
                    if scanType == "seat" {
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
                                                    isGoldenTicket = scanResponse.isGoldenTicket ?? false
                                                    playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
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
                                                    playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                        withAnimation {
                                                            isPreScanned = false
                                                            isTicketValid = false
                                                        }
                                                    }
                                                    isScanning = false
                                                    
                                                } else {
                                                    if let message = scanResponse.message, !message.isEmpty {
                                                        playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                            lookupByOrderResultViewModel.errorMessage = message
                                                            showOfflineAlert = true
                                                        }
                                                    } else {
                                                        isInvalidTicket = true
                                                        playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                            withAnimation { isInvalidTicket = false }
                                                        }
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
                                    playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation { isInvalidTicket = false }
                                    }
                                    isScanning = false
                                }
                            }
                        }
                        
                    } else {
                        isInvalidSeatTicket = true
                        playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isInvalidSeatTicket = false
                            }
                        }
                        isScanning = false
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
    
    func playScanFeedback(beep: Bool, haptic: Bool) {
        if beep {
            if let soundURL = Bundle.main.url(forResource: "beep", withExtension: "mp3") {
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
        if haptic {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) // Haptic vibration
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
