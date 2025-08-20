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

struct ScannerView: View, Equatable {
    @EnvironmentObject var stringManager: StringManager
    @Binding var seat: SeatModel?
    @Binding var scannerLineAnimation: Bool
        @State private var scannedCode: String?
    @State private var scanResult: String?
    @State private var isScanning = true
    @State private var flashLight: AVCaptureDevice?
    @State private var scanViewHeight: CGFloat =  UIDevice.isIpad && UIDevice.isLandscape ? UIScreen.main.bounds.height / 2.3 :  UIScreen.main.bounds.height / 3
    @State private var linePosition: CGFloat
    private let lineSpeed: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 120.0 : 90.0
    @State private var timer: Timer?
    @State private var isScannerActive = true
    @State private var isCustomColorVisible = false
    @State private var isStopScanVisible = false
    @State private var scannerController: ScannerViewController? =  ScannerViewController()
    @State private var isScanned = false
    @State private var scannedTime: String?
    @State private var isLoading = false
    @AppStorage("showCode") private var savedShowCode: String?
    @AppStorage("isOfflineMode") private var isOffline: Bool = false
    @AppStorage("isMerchandise") private var isMerchandise: Bool?
    @AppStorage("kShowScanStats") private var showScanStats: Bool?
    @AppStorage("kPauseScanTimeout") var pauseScanTimeout: Int = 0
    @AppStorage("kShouldPlayHaptic") var shouldPlayHaptic: Bool?
    @AppStorage("kAutoEnableFlashTimeout") private var autoEnableFlashTimeout: Bool = false
    @AppStorage("kAutoEnableFlashDelay") private var autoEnableFlashDelay: Int = 10
    @AppStorage("kDuplicateScanSuppression") private var duplicateScanSuppression: Int = 10
    @State private var lastScanTimes: [String: Date] = [:]
    @State private var suppressedOnce: Set<String> = []
    @State private var apiPreviouslyScannedQRCodes: Set<String> = []
    @State private var inactivityTimer: Timer?
    @State private var flashAutoOffTimer: Timer?
    @State private var flashAutoOnTimer: Timer?
    // Core Data context
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isOfflineMode = false
    // Indicates if merchandise mode is enabled (runtime)
    @State private var isMerchandiseMode = false
    @State private var shouldPlayHapticNew = false
    // Duplicate scan suppression value (runtime)
    @State private var duplicateScanSuppressionNew = 0
    
    @State private var toastMessage: String?
    @State private var showToast = false
    
    @Binding var orderDateScanned: String
    @Binding var tsScannedDate: String
    @Binding var isGoldenTicket: Bool
    @Binding var isFullScreen: Bool
    @Binding var invalidMessage: String
    @StateObject private var viewModel = ScanningStatsViewModel(context: PersistenceController.shared.container.viewContext)
    @State var isVisibleText: Bool = false
    @State private var dragLocation: CGPoint = .zero
    @State private var isFlashOn = false
    let dragAreaSize: CGSize = CGSize(width: 70.adaptiveForIpad, height: 70.adaptiveForIpad)
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
    @ObservedObject var landingView:LandingViewModel
    // Controls visibility of the offline alert (binding from parent)
    @Binding var showOfflineAlert: Bool
    // Indicates if the input field is active
    @State private var isInputActive: Bool = false
    // Stores the scanned code from external input
    @State private var scannedExternalCode: String = ""
    
    @State private var isCameraAuthorized: Bool = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    //    @StateObject private var landingViewModel = LandingViewModel(lookupByOrderResultViewModel: LookupByOrderResultViewModel(managedObjectContext: PersistenceController.shared.container.viewContext))
    @AppStorage("deviceScanCount") private var deviceScanCount: Int = 0
    
    @Binding var scanResultEnum: ScanResult
    
    let controller: ScannerViewController
    
    static func == (lhs: ScannerView, rhs: ScannerView) -> Bool {
        return lhs.controller == rhs.controller
    }
    
    /// Initializes the ScannerView with all required bindings and view models
    init(seat: Binding<SeatModel?>,
         scannerLineAnimation: Binding<Bool>,
         orderDateScanned: Binding<String>,
         tsScannedDate: Binding<String>,
         invalidMessage: Binding<String>,
         isFullScreen: Binding<Bool>,
         isScanningCell: Binding<Bool>,
         isGoldenTicket: Binding<Bool>,
         scannerViewModel: ScannerViewModel,
         lookupByOrderResultViewModel: LookupByOrderResultViewModel,
         landingView: LandingViewModel,
         controller: ScannerViewController,
         scanResultEnum: Binding<ScanResult>,
         showOfflineAlert: Binding<Bool>) {
        _linePosition = State(initialValue: 0)
        self._seat = seat
        _scannerLineAnimation = scannerLineAnimation
        _orderDateScanned = orderDateScanned
        _tsScannedDate = tsScannedDate
        _isFullScreen = isFullScreen
        _isScanningCell = isScanningCell
        _isGoldenTicket = isGoldenTicket
        self.scannerViewModel = scannerViewModel
        self.lookupByOrderResultViewModel = lookupByOrderResultViewModel
        self.landingView = landingView
        _showOfflineAlert = showOfflineAlert
        _invalidMessage = invalidMessage
        self.controller = controller
        _scanResultEnum = scanResultEnum
    }
    
    // Main view body for the scanner UI, handles camera, overlays, and user interactions
    var body: some View {
        VStack {
            ZStack {
                // Camera scanner view with scan callback and controller setup
                ZStack {
                    CameraScannerView(
                        isScanning: $isScanningCell,
                        controller: controller,
                        onScan: { scanned in
                            scannedCode = scanned
                            sendScanRequest(qr: scanned) // Handle scan result
                            resetInactivityTimer()  // Reset inactivity timer on scan
                        }, onControllerCreated: { controller in
                            DispatchQueue.main.async {
                                scannerController = controller
                                controller.isScanningBinding = $isScanningCell // Bind scanning state
                            }
                        }
                        // Bind scanning state
                    )
                }
                .padding(.bottom,-30)
                .frame(height: isFullScreen ? nil : scanViewHeight.adaptiveForIpadScan)
                .frame(maxWidth: .infinity)
                .overlay {
                    // Animated scan line overlay
                    VStack {
                        if !isCustomColorVisible && !isAnyOverlayDisplayed && !isStopScanVisible {
                            if isCameraAuthorized {
                                Rectangle()
                                    .frame(height: 1.5)
                                    .foregroundColor(.red)
                                    .shadow(color: .black, radius: 1.5)
                                    .offset(y: linePosition - ((isFullScreen ? UIScreen.main.bounds.height : scanViewHeight.adaptiveForIpadScan) / (isFullScreen ? 2 : UIDevice.current.userInterfaceIdiom == .pad ? 2.1 : 2.2)))
                                    .onAppear {
                                        startLineAnimation()
                                    }
                                    .padding(.bottom, 20)
                            }
                        }
                    }
                }
                .onChange(of: isScanning) { newValue in // Start or stop scanning based on state
                    if newValue {
                        scannerController?.startScanning()
                    } else {
                        scannerController?.stopScanning()
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    isCameraAuthorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
                    if isCameraAuthorized {
                        startLineAnimation()
                    }
                }
                
                if !isCameraAuthorized {
                    Color.neutralText
                        .frame(height: isFullScreen ? nil : scanViewHeight + 30.adaptiveForIpad)
                        .frame(maxWidth: .infinity)
                        .opacity(1)
                        .padding(.bottom, -30)
                }

                VStack {
                    HStack {
                        Text("")
                    }
                    HStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack {
                                if isCameraAuthorized {
                                    // Flashlight toggle icon and gesture
                                    Image(isFlashOn ? "FlashOff" : "FlashOn")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40.adaptiveForIpad, height: 40.adaptiveForIpad)
                                        .padding(5)
                                }
                                Spacer()
                            }
                        }
                        .frame(width: dragAreaSize.width, height: dragAreaSize.height)
                            .background(.black.opacity(0.000001))
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let location = value.location
                                        if isInsideBounds(location) {
                                            if !isFlashOn {
                                                isFlashOn = true
                                                toggleTorch(status: true) // Turn on flashlight
                                            }
                                        } else {
                                            if isFlashOn {
                                                isFlashOn = false
                                                toggleTorch(status: false) // Turn off flashlight
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
                    .padding(.top, isFullScreen ? 20 : 0)
                    
                    Spacer()
                    
                    // External scanner and scan stats UI
                    HStack {
                        if !isFullScreen {
                            // Button to activate external scanner input
                            Button {
                                DispatchQueue.main.async {
                                    externalScannerAction()
                                    isCustomColorVisible = true
                                    isInputActive = true
                                }
                            } label: {
                                Image("Scan_icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30.adaptiveForIpad, height: 30.adaptiveForIpad)
                                    .padding()
                            }
                        } else {
                            Text("")
                        }
                        if let stats = viewModel.stats, showScanStats ?? false, !isMerchandiseMode {
                            Spacer()
                            // Display scan statistics
                            Text("\(stringManager.strings.stats.scanned): \(isOffline ? deviceScanCount : stats.seatsScannedByDevice ?? 0)     \(stringManager.strings.stats.scannable): \(stats.seatsScannable ?? 0)")
                                .font(.verlagBookAdaptive(size: 16))
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .padding(.bottom, -30)
                                .foregroundColor(Color.primaryText)
                                .opacity(isVisibleText ? 1 : 0)
                                .animation(.easeInOut(duration: 0.3), value: isVisibleText)
                            
                            Spacer()
                            
                        } else {
                            Spacer()
                        }
                        
                        // Full screen toggle button
                        Button {
                            withAnimation {
                                resetScanner()
                                isFullScreen.toggle()
                            }
                        } label: {
                            Image(isFullScreen ? "video_Default_screen_icon" : "video_full_screen_icon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30.adaptiveForIpad, height: 30.adaptiveForIpad)
                                .background(Color.clear)
                                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                .padding()
                        }
                    }
                    .allowsHitTesting(true)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, isFullScreen ? 20 : 0)
                }
                .frame(maxHeight: isFullScreen ? .infinity : scanViewHeight, alignment: .bottom)
                
                // Overlay for external barcode input
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
                        
                        Color.secondaryBg
                            .opacity(1)
                            .frame(height: scanViewHeight + 30.adaptiveForIpad)
                            .frame(height: 50.adaptiveForIpad)
                        
                            .overlay(
                                VStack(spacing: 12) {
                                    Text(stringManager.strings.attached)
                                        .lineLimit(0)
                                        .font(.verlagBookAdaptive(size: 25))
                                        .foregroundColor(Color.primaryText)
                                        .padding(.top, -40)
                                    Image("scan__cirle_icon")
                                        .resizable()
                                    //  .scaleEffect(x: -1, y: 1)
                                        .scaledToFit()
                                        .frame(width: 100.adaptiveForIpad, height: 100.adaptiveForIpad)
                                        .onTapGesture {
                                            stopLineAnimation()
                                            resetScanner()
                                        }
                                    Spacer()
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
                
                // Overlay for pause scan UI
                if isStopScanVisible && !isFullScreen && !isCustomColorVisible {
                    Color.secondaryBg
                        .opacity(1)
                        .frame(height: scanViewHeight + 30.adaptiveForIpad)
                        .frame(height: 50.adaptiveForIpad)
                        .overlay(
                            Text(stringManager.strings.scanner)
                                .font(.verlagBoldAdaptive(size: 20))
                                .foregroundColor(Color.primaryText)
                                .onTapGesture {
                                    resetScanner()
                                }
                        ).onTapGesture {
                            resetScanner()
                        }
                        .padding(.bottom, -30)
                }
            }.onAppear {
                Task {
                    await viewModel.fetchStats() // Fetch scan stats on appear
                }
            }
            .onChange(of: scannerViewModel.shouldResetScanner) { newValue in
                if newValue {
                    resetCameraView()  // Reset camera view if requested
                }
                // if scan states is true then call the api
                if UserDefaults.standard.bool(forKey: "kShowScanStats") {
                    Task {
                        await viewModel.fetchStats()
                    }
                }
            }
        } // Listen for camera reset notifications
        .onReceive(NotificationCenter.default.publisher(for: .resetCameraView)) { _ in
            if isStopScanVisible {
                resetScanner()
            } else if isCustomColorVisible {
                resetScanner()
            }
            else {
                resetCameraView()
            }
        }
        // Setup and state management on appear/disappear and state changes
        .onAppear {
            setupScanner() // Initial scanner setup
            startInactivityTimer() // Start inactivity timer
            isOfflineMode = isOffline
            isMerchandiseMode = isMerchandise ?? false
            shouldPlayHapticNew = shouldPlayHaptic ?? false
            
            duplicateScanSuppressionNew = duplicateScanSuppression
            withAnimation {
                isVisibleText = true
            }
        }
        .onDisappear {
            stopLineAnimation() // Stop scan line animation
            stopInactivityTimer()  // Stop inactivity timer
            isOfflineMode = isOffline
            isMerchandiseMode = isMerchandise ?? false
        }
        .onChange(of: keyboardObserver.isKeyboardVisible) { isVisible in
            if isVisible {
                stopLineAnimation()
            } else {
                resetScanner()
            }
        }
        .onChange(of: scannerLineAnimation) { isVisible in
            if !isVisible {
                stopLineAnimation()
            } else {
                resetScanner()
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
                lastScanTimes.removeAll()
            }
        }
        .onChange(of: isFullScreen) { _ in
            stopLineAnimation()
            startLineAnimation()
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
            startFlashInactivityTimer() // Start flash inactivity timer
        }
        .onDisappear {
            stopFlashInactivityTimer() // Stop flash inactivity timer
        }
    }
    
    // Starts the timer that will automatically turn on the flashlight after a delay
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
    
    // Stops the flashlight inactivity timer
    private func stopFlashInactivityTimer() {
        flashAutoOnTimer?.invalidate()
        flashAutoOffTimer?.invalidate()
    }
    
    private func resetFlashInactivityTimer() {
        startFlashInactivityTimer()
    }
    
    // Sets up the scanner and its initial configuration
    private func setupScanner() {
        flashLight = AVCaptureDevice.default(for: .video)
    }
    
    // Starts the animation for the scanning line
    private func startLineAnimation() {
        isStopScanVisible = false
        if isCameraAuthorized {
            let animationHeight = isFullScreen ? UIScreen.main.bounds.height * 1 : scanViewHeight
            if isFullScreen {
                linePosition = 0
            }
            withAnimation(Animation.linear(duration: Double(animationHeight / lineSpeed)).repeatForever(autoreverses: true)) {
                linePosition = animationHeight
            }
        }
    }
    
    // Stops the animation for the scanning line
    private func stopLineAnimation() {
        isStopScanVisible = true
        linePosition = 0
    }
    
    // Computed property to check if any overlay is displayed
    private var isAnyOverlayDisplayed: Bool {
        isFullScreen && scanResult != .none
    }
    
    // Resets the scanner to its initial state
    private func resetScanner() {
        DispatchQueue.global(qos: .userInitiated).async {
            scannerController?.isStopSessionByME = false
            scannerController?.captureSession?.startRunning()
            scannerController?.checkCameraSessionRunning()
        }
        isCustomColorVisible = false
        isStopScanVisible = false
        scannedCode = nil
        scanResult = nil
        isScanning = true
        isScannerActive = true
        isScanningCell = true
        if isFullScreen {
            linePosition = 0
        }
        startLineAnimation()
        startInactivityTimer()
        startFlashInactivityTimer()
    }
    
    
    // Resets the camera view and scanning state
    private func resetCameraView() {
        DispatchQueue.global(qos: .userInitiated).async {
            scannerController?.isStopSessionByME = false
            scannerController?.captureSession?.startRunning()
            scannerController?.checkCameraSessionRunning()
        }
        DispatchQueue.main.async {
            isCustomColorVisible = false
            isStopScanVisible = false
            scannedCode = nil
            scanResult = nil
            isScanning = true
            isScannerActive = true
            isScanningCell = true
            startLineAnimation()
            startInactivityTimer()
            startFlashInactivityTimer()
        }
    }
    
    // Starts the inactivity timer to pause scanning after a period of inactivity
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
    
    // Stops the inactivity timer
    private func stopInactivityTimer() {
        timer?.invalidate()
    }
    
    private func resetInactivityTimer() {
        startInactivityTimer()
    }
    
    private func stopScanner() {
        isScannerActive = false
        scannerController?.isStopSessionByME = true
        scannerController?.captureSession?.stopRunning()
        
    }
    
    private func activateColorOverlay() {
        isStopScanVisible = true
    }
    
    // Toggles the device torch (flashlight) on or off
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
    
    // Handles the action for using an external barcode scanner
    func externalScannerAction() {
        isUtilizingExternalBarcode = true
        isExternalInputFocused = true
        stopScanner()
        
        withAnimation(.easeInOut(duration: 0.2)) {
            showExternalBarcodeView = true
        }
    }
    
    
    // Checks if a point is inside the bounds of the drag area for the flashlight
    private func isInsideBounds(_ location: CGPoint) -> Bool {
        return location.x >= 0 &&
        location.y >= 0 &&
        location.x <= dragAreaSize.width &&
        location.y <= dragAreaSize.height
    }
    
    /// Handles a scanned QR code for seats or merchandise.
    /// Supports both online and offline modes, handles duplicate suppression,
    /// updates Core Data if offline, or hits API endpoints if online.
    private func sendScanRequest(qr: String) {
        
        // MARK: - Step 1: Determine scan type and clean up QR string
        
        guard let (scanType, cleanedQR, qrCodes) = parseQR(qr) else { return }

        // MARK: - Step 2: Duplicate suppression check
        duplicateSepration(cleanedQR: cleanedQR)
        
        // MARK: - Step 3: Offline mode scanning
        if isOfflineMode {
            let separatedQRCodes = qrCodes.joined(separator: "-")
            if qr.allSatisfy({ $0.isNumber }) {
                // Additional offline barcode check
                offlineBarCodeCheck(scanType: scanType, qr: qr, cleanedQR: cleanedQR)
            } else if isMerchandiseMode {
                // Offline merchandise lookup
                offlineMerchandiseModel(scanType: scanType, qrCodes: separatedQRCodes, cleanedQR: cleanedQR)
            } else {
                // Offline seat lookup
                offlineSeatMode(scanType: scanType, separatedQRCodes: separatedQRCodes, cleanedQR: cleanedQR)
            }
        } else {
            // MARK: - Step 4: Online mode scanning
            
            // Online seat barcode scan
            if qr.allSatisfy({ $0.isNumber }) {
                onlineBarCodeAPI(rawQR: qr, cleanedQR: cleanedQR)
            } else if isMerchandiseMode {
                // Online merchandise QR scan
                OnlineMerchandiseAPI(scanType: scanType, qrCodes: qrCodes)
            } else {
                onlineScanSeatAPI(scanType: scanType, qrCodes: qrCodes, cleanedQR: cleanedQR)
            }
        }
    }
    // MARK: Check QR Type
    private func parseQR(_ qr: String) -> (scanType: String, cleanedQR: String, qrCodes: [String])? {
        var scanType = ""
        var cleanedQR = ""

        if qr.allSatisfy({ $0.isNumber }) {
            scanType = "barcode"
            cleanedQR = qr
        } else if qr.contains("{\"seat\":[") {
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
        } else {
            scanResultEnum = .invalidTicket(message: isMerchandiseMode ? StringManager.shared.strings.orderDetail.invalidProduct : StringManager.shared.strings.orderDetail.invalidTicket)
            dismissPopUp(scannerResult: .invalid)
        }

        let qrCodes = cleanedQR.components(separatedBy: ",").filter { !$0.isEmpty }
        guard !qrCodes.isEmpty else { return nil }

        return (scanType, cleanedQR, qrCodes)
    }
    //MARK: duplicate Sepration
    func duplicateSepration(cleanedQR: String){
        let now = Date()
        let suppressionSeconds = Double(duplicateScanSuppressionNew)
        
        let beforeCleanup = lastScanTimes.count
        
        // Cleanup expired scans from `lastScanTimes`
        lastScanTimes = lastScanTimes.filter { now.timeIntervalSince($0.value) < suppressionSeconds }
        print("🧹 Cleaned up old QR entries. Before: \(beforeCleanup), After: \(lastScanTimes.count)")
        
        // Check if this QR was scanned recently
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
        
        // Record new scan time
        lastScanTimes[cleanedQR] = now
    }
    //MARK: offline merchandise mode
    func offlineMerchandiseModel(scanType: String, qrCodes: String, cleanedQR: String){
        if scanType == "merch" {
            // Offline merchandise lookup in Core Data
            let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "qrCode == %@", qrCodes)
            
            do {
                let results = try viewContext.fetch(fetchRequest)
                if let product = results.first {
                    let totalQty = product.qty
                    let scannedQty = product.qtyScanned
                    
                    if scannedQty < totalQty {
                        // ✅ Valid scan, mark as scanned and increment
                        product.qtyScanned += 1
                        product.locally_scanned += 1
                        product.date_scanned = Date()
                        try viewContext.save()
                        
                        // Optional: update UI info
                        scanResultEnum = .validMerch(orderName: product.name ?? "",
                                                     variantName: product.variantName ?? "")
                        dismissPopUp(scannerResult: .valid)
                    } else {
                        // Set state to show previous scan view
                        var time: String = ""
                        if let scannedDate = product.date_scanned {
                            let formattedDate = scannedDate.formatToTimeString()
                            time = "\(formattedDate)"
                        }
                        
                        scanResultEnum = .preScannedMerch(orderName: product.name ?? "", variantName: product.variantName ?? "", scannedTime: time, tsScannedDate: time)
                        dismissPopUp(scannerResult: .previouslyScanned)
                    }
                } else {
                    // ❌ No matching product found
                    scanResultEnum = .invalidTicket(message: StringManager.shared.strings.orderDetail.invalidProduct)
                    dismissPopUp(scannerResult: .invalid)
                }
            } catch {
                print(error.localizedDescription)
            }
        } else if scanType == "seat" {
            // wrong mode to scan like seat in march
            scanResultEnum = .incorrectTicketMode
            dismissPopUp(scannerResult: .invalid)
        } else {
            
        }
    }
    //MARK: offline seat mode
    func offlineSeatMode(scanType: String, separatedQRCodes: String, cleanedQR: String){
        if scanType == "seat" {
            let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "qrCode == %@", separatedQRCodes)
            
            do {
                let results = try viewContext.fetch(fetchRequest)
                if let seatEntity = results.first {
                    if let scannedTime = seatEntity.date_scanned {
                        // Already scanned seat
                        scanResultEnum = .preScannedTicket(orderName: seatEntity.order?.buyerName ?? "Blocked Seat", orderNumber: seatEntity.orderId.map(String.init) ?? "N/A", scannedTime: scannedTime.formatToTimeString(), tsScannedDate: scannedTime.formatToTimeString())
                        dismissPopUp(scannerResult: .previouslyScanned)
                    } else {
                        // Mark as scanned
                        seatEntity.locally_scanned += 1
                        deviceScanCount += 1
                        seatEntity.date_scanned = Date()
                        try viewContext.save()
                        scanResultEnum = .validTicket(orderName: seatEntity.order?.buyerName ?? "Blocked Seat", orderNumber: seatEntity.orderId.map(String.init) ?? "N/A", isGoldenTicket: false)
                        dismissPopUp(scannerResult: .valid)
                        lastScanTimes[cleanedQR] = Date()
                        suppressedOnce.remove(cleanedQR)
                    }
                } else {
                    // Invalid offline seat QR
                    scanResultEnum = .invalidTicket(message: StringManager.shared.strings.orderDetail.invalidTicket)
                    dismissPopUp(scannerResult: .invalid)
                }
            } catch {
                
            }
        } else {
            // wrong mode to scan qr
            scanResultEnum = .incorrectTicketMode
            dismissPopUp(scannerResult: .invalid)
        }
    }
    //MARK: offline BarCode check
    func offlineBarCodeCheck(scanType: String, qr: String, cleanedQR: String){
        if scanType == "barcode" {
            let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "barcode == %@", qr)
            
            do {
                let results = try viewContext.fetch(fetchRequest)
                if let seatEntity = results.first {
                    if let scannedTime = seatEntity.date_scanned {
                        scanResultEnum = .preScannedTicket(orderName: seatEntity.order?.buyerName ?? StringManager.shared.strings.offline.blockedTicket, orderNumber: seatEntity.orderId.map(String.init) ?? "", scannedTime: scannedTime.formatted(date: .omitted, time: .shortened), tsScannedDate: scannedTime.formatted(date: .omitted, time: .shortened))
                        dismissPopUp(scannerResult: .previouslyScanned)
                    } else {
                        seatEntity.locally_scanned += 1
                        deviceScanCount += 1
                        seatEntity.date_scanned = Date()
                        try viewContext.save()
                        scanResultEnum = .validTicket(orderName: seatEntity.order?.buyerName ?? StringManager.shared.strings.offline.blockedTicket, orderNumber: seatEntity.orderId.map(String.init) ?? "N/A", isGoldenTicket: false)
                        dismissPopUp(scannerResult: .valid)
                        lastScanTimes[cleanedQR] = Date()
                        suppressedOnce.remove(cleanedQR)
                    }
                } else {
                    scanResultEnum = .invalidTicket(message: stringManager.strings.offline.invalidBarcode)
                    dismissPopUp(scannerResult: .invalid)
                }
            } catch {
                scanResultEnum = .invalidTicket(message: stringManager.strings.offline.invalidBarcode)
                dismissPopUp(scannerResult: .invalid)
            }
        }
    }
    
    //MARK: barCodeAPi
    func onlineBarCodeAPI(rawQR: String, cleanedQR: String){
            IQAPIClient.scanTicketBarcode(code: savedShowCode ?? "", barcode: rawQR) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let responseData):
                        if let responseDict = responseData as? [String: Any], let message = responseDict["message"] as? String {
                            if message == "Previously Scanned" {
                                scanResultEnum = .preScannedTicket(orderName: (responseDict["buyer_name"] as? String)?.capitalized ?? "", orderNumber: String(responseDict["oid"] as? Int ?? 0), scannedTime: responseDict["date_scanned"] as? String ?? "", tsScannedDate: responseDict["tsScanned"] as? String ?? "")
                                dismissPopUp(scannerResult: .previouslyScanned)
                                
                            } else {
                                scanResultEnum = .validTicket(orderName: (responseDict["buyer_name"] as? String)?.capitalized ?? StringManager.shared.strings.offline.blockedTicket,
                                                              orderNumber: String(responseDict["oid"] as? Int ?? 0),
                                                              isGoldenTicket: (responseDict["is_golden_ticket"] == nil))
                                dismissPopUp(scannerResult: .valid)
                                Task {
                                    await viewModel.fetchStats()
                                }
                                lastScanTimes[cleanedQR] = Date()
                                suppressedOnce.remove(cleanedQR)
                            }
                        }
                    case .failure(let error):
                        if NetworkMonitor.shared.isNetworkAvailable() {
                            invalidMessage = error.localizedDescription
                        } else {
                            invalidMessage = StringManager.shared.strings.noInternet.description
                        }
                        scanResultEnum = .invalidTicket(message: invalidMessage)
                        dismissPopUp(scannerResult: .invalid)
                    }
                }
            }
    }
    
    //MARK: MerchandiseAPI
    
    func OnlineMerchandiseAPI (scanType: String, qrCodes: [String]){
        if scanType == "merch" {
            IQAPIClient.scanProductQrCode(code: savedShowCode ?? "", qr: qrCodes) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let responseData):
                        if let responseDict = responseData as? [String: Any] {
                            let message = responseDict["message"] as? String ?? ""
                            let ts: String
                            if let tsString = responseDict["tsScanned"] as? String {
                                ts = tsString
                            } else if let tsString = responseDict["tsScanned"] as? Double {
                                ts = String(tsString)
                            } else {
                                ts = ""
                            }
                            
                            let isValid = responseDict["valid"] as? Bool ?? false
                            
                            let name = responseDict["name"] as? String ?? ""
                            let variantName = responseDict["variantName"] as? String ?? ""
                            
                            if message.contains("Previously scanned") || isValid {
                                if message.contains("Previously scanned") {
                                    scanResultEnum = .preScannedMerch(orderName: name,
                                                                      variantName: variantName,
                                                                      scannedTime: ts.formatToDate(),
                                                                      tsScannedDate: ts)
                                    dismissPopUp(scannerResult: .previouslyScanned)
                                } else {
                                    scanResultEnum = .incorrectTicketMode
                                    dismissPopUp(scannerResult: .valid)
                                }
                            } else {
                                // ❗ Show error message if valid is false
                                scanResultEnum = .invalidTicket(message: message)
                                dismissPopUp(scannerResult: .invalid)
                            }
                        }
                        
                    case .failure(let error):
                        // ❗ Show error if API call failed entirely
                      
                        if NetworkMonitor.shared.isNetworkAvailable() {
                            invalidMessage = error.localizedDescription
                        } else {
                            invalidMessage = StringManager.shared.strings.noInternet.description
                        }
                        scanResultEnum = .invalidTicket(message: invalidMessage)
                        dismissPopUp(scannerResult: .invalid)
                    }
                }
            }
        } else {
            // Offline or wrong scan type
            scanResultEnum = .incorrectTicketMode
            dismissPopUp(scannerResult: .invalid)
            isScanning = false
        }
    }
    
    //MARK: onlineSeatApi
    func onlineScanSeatAPI(scanType: String, qrCodes: [String], cleanedQR: String){
        // Online seat QR scan
        if scanType == "seat" {
            IQAPIClient.scanTicketQrCode(code: savedShowCode ?? "", type: scanType, qr: qrCodes) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let scanResponse):
                        if scanResponse.valid {
                            scanResultEnum = .validTicket(orderName: scanResponse.buyerName ?? "", orderNumber: String(scanResponse.oid ?? 0), isGoldenTicket: scanResponse.isGoldenTicket ?? false)
                            dismissPopUp(scannerResult: .valid)
                            
                            seat?.scannedTime = Date()
                            isScanning = false
                            Task {
                                await viewModel.fetchStats()
                            }
                            lastScanTimes[cleanedQR] = Date()
                            suppressedOnce.remove(cleanedQR)
                        } else if scanResponse.message?.lowercased() == "previously scanned".lowercased() {
                            scanResultEnum = .preScannedTicket(orderName: String(scanResponse.oid ?? 0), orderNumber: scanResponse.buyerName ?? "", scannedTime: orderDateScanned, tsScannedDate: scanResponse.tsScanned ?? "")
                            dismissPopUp(scannerResult: .previouslyScanned)
                            isScanning = false
                            
                        } else {
                            if let message = scanResponse.message, !message.isEmpty {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    lookupByOrderResultViewModel.errorMessage = message
                                    showOfflineAlert = true
                                }
                            } else {
                                scanResultEnum = .invalidTicket(message: "")
                                dismissPopUp(scannerResult: .invalid)
                            }
                            isScanning = false
                        }
                           
                    case .failure(let error):
                        if NetworkMonitor.shared.isNetworkAvailable() {
                            invalidMessage = error.localizedDescription
                        } else {
                            invalidMessage = StringManager.shared.strings.noInternet.description
                        }
                        scanResultEnum = .invalidTicket(message: invalidMessage)
                        dismissPopUp(scannerResult: .valid)
                        isScanning = false
                    }
                }
            }
            
        } else {
            scanResultEnum = .incorrectTicketMode
            dismissPopUp(scannerResult: .invalid)
            isScanning = false
        }
    }
    //MARK: dismised scaned popup

    func dismissPopUp(scannerResult: ScannerResult){
        scannerViewModel.playScanFeedback(scannerResult: scannerResult, haptic: shouldPlayHapticNew)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            withAnimation {
                scanResultEnum = .none
            }
        }
    }
    
}
