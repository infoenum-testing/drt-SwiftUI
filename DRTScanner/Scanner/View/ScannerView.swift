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
    // The currently selected seat model (binding from parent)
    @Binding var seat: SeatModel?
    // Stores the last scanned code
    @State private var scannedCode: String?
    // Stores the scan result string
    @State private var scanResult: String?
    // Indicates if scanning is active
    @State private var isScanning = true
    // Reference to the device's flashlight
    @State private var flashLight: AVCaptureDevice?
    // Height of the scan view area
    @State private var scanViewHeight: CGFloat = UIScreen.main.bounds.height / 3
    // Position of the animated scan line
    @State private var linePosition: CGFloat
    // Speed of the scan line animation
    private let lineSpeed: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 120.0 : 90.0
    // Timer for scan line animation
    @State private var timer: Timer?
    // Indicates if the scanner is active
    @State private var isScannerActive = true
    // Controls visibility of custom color overlay
    @State private var isCustomColorVisible = false
    // Controls visibility of stop scan overlay
    @State private var isStopScanVisible = false
    // Reference to the scanner controller
    @State private var scannerController: ScannerViewController?
    // Indicates if a scan has occurred
    @State private var isScanned = false
    // Stores the time of the last scan
    @State private var scannedTime: String?
    // Indicates if loading is in progress
    @State private var isLoading = false
    // Stores the saved show code from user defaults
    @AppStorage("showCode") private var savedShowCode: String?
    // Indicates if offline mode is enabled
    @AppStorage("isOfflineMode") private var isOffline: Bool = false
    // Indicates if merchandise mode is enabled
    @AppStorage("isMerchandise") private var isMerchandise: Bool?
    // Controls visibility of scan stats
    @AppStorage("kShowScanStats") private var showScanStats: Bool?
    // Indicates if beep sound should play on scan
    @AppStorage("kShouldPlayBeep") private var shouldPlayBeep: Bool?
    // Timeout for pausing scan
    @AppStorage("kPauseScanTimeout") var pauseScanTimeout: Int = 0
    // Indicates if haptic feedback should play on scan
    @AppStorage("kShouldPlayHaptic") var shouldPlayHaptic: Bool?
    // Enables auto flash after inactivity
    @AppStorage("kAutoEnableFlashTimeout") private var autoEnableFlashTimeout: Bool = false
    // Delay before auto flash turns on
    @AppStorage("kAutoEnableFlashDelay") private var autoEnableFlashDelay: Int = 10
    // Time window for duplicate scan suppression
    @AppStorage("kDuplicateScanSuppression") private var duplicateScanSuppression: Int = 10
    // Tracks last scan times for duplicate suppression
    @State private var lastScanTimes: [String: Date] = [:]
    // Tracks codes that have been suppressed once
    @State private var suppressedOnce: Set<String> = []
    // Tracks QR codes previously scanned via API
    @State private var apiPreviouslyScannedQRCodes: Set<String> = []
    // Timer for inactivity
    @State private var inactivityTimer: Timer?
    // Timer for auto turning off flash
    @State private var flashAutoOffTimer: Timer?
    // Timer for auto turning on flash
    @State private var flashAutoOnTimer: Timer?
    // Core Data context
    @Environment(\.managedObjectContext) private var viewContext
    // Indicates if beep sound should play (runtime)
    @State private var shouldPlayBeepSound = false
    // Indicates if offline mode is enabled (runtime)
    @State private var isOfflineMode = false
    // Indicates if merchandise mode is enabled (runtime)
    @State private var isMerchandiseMode = false
    // Indicates if haptic feedback should play (runtime)
    @State private var shouldPlayHapticNew = false
    // Duplicate scan suppression value (runtime)
    @State private var duplicateScanSuppressionNew = 0
    
    @State private var toastMessage: String?
    @State private var showToast = false
    // Indicates if the ticket is valid (binding from parent)
    @Binding var isTicketValid: Bool
    // Indicates if the ticket was previously scanned (binding from parent)
    @Binding var isPreScanned: Bool
    // Indicates if the ticket is invalid (binding from parent)
    @Binding var isInvalidTicket: Bool
    // Indicates if the seat ticket is invalid (binding from parent)
    @Binding var isInvalidSeatTicket: Bool
    // Indicates if the merchandise ticket is invalid (binding from parent)
    @Binding var isInvalidMerchTicket: Bool
    // Stores the order name (binding from parent)
    @Binding var orderName: String
    // Stores the order number (binding from parent)
    @Binding var orderNumber: String
    // Stores the date the order was scanned (binding from parent)
    @Binding var orderDateScanned: String
    // Indicates if the ticket is a golden ticket (binding from parent)
    @Binding var isGoldenTicket: Bool
    // Indicates if the merchandise ticket is valid (binding from parent)
    @Binding var isMerchTicketValid: Bool
    // Indicates if the view is in full screen mode (binding from parent)
    @Binding var isFullScreen: Bool
    // Indicates if the merchandise was previously scanned
    @Binding var isMerchPreScanned: Bool
    @Binding var invalidMessage: String
    // ViewModel for scanning stats
    @StateObject private var viewModel = ScanningStatsViewModel(context: PersistenceController.shared.container.viewContext)
    // Controls visibility of scan stats text
    @State var isVisibleText: Bool = false
    // Stores the drag location for gestures
    @State private var dragLocation: CGPoint = .zero
    // Indicates if the flash is on
    @State private var isFlashOn = false
    // Size of the drag area for flash control
    let dragAreaSize: CGSize = CGSize(width: 80.adaptiveForIpad, height: 80.adaptiveForIpad)
    // Indicates if the scanner cell is scanning (binding from parent)
    @Binding var isScanningCell: Bool
    // ViewModel for scanner logic
    @ObservedObject var scannerViewModel: ScannerViewModel
    // Indicates if a scan is being processed
    @State private var isProcessingScan = false
    // Stores the last scanned code
    @State private var lastScannedCode: String?
    // Stores the time of the last scan
    @State private var lastScannedTime: TimeInterval = 0
    // Indicates if the scanner view is expanded
    @State private var scannerViewExpanded = false
    // Indicates if an external barcode is being used
    @State private var isUtilizingExternalBarcode = false
    // Controls visibility of the external barcode view
    @State private var showExternalBarcodeView = false
    // Focus state for external input
    @FocusState private var isExternalInputFocused: Bool
    // Observes keyboard events
    @StateObject private var keyboardObserver = KeyboardObserver()
    // ViewModel for order lookup results
    @ObservedObject var lookupByOrderResultViewModel: LookupByOrderResultViewModel
    // Controls visibility of the offline alert (binding from parent)
    @Binding var showOfflineAlert: Bool
    // Indicates if the input field is active
    @State private var isInputActive: Bool = false
    // Stores the scanned code from external input
    @State private var scannedExternalCode: String = ""
    // Audio player for beep sound
    @State private var audioPlayer: AVAudioPlayer?
    
    @Binding var merchOrderName: String
    
    @Binding var merchVariantName: String
    
    @State private var isCameraAuthorized: Bool = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    
    @AppStorage("deviceScanCount") private var deviceScanCount: Int = 0

    /// Initializes the ScannerView with all required bindings and view models
    init(seat: Binding<SeatModel?>,
         isTicketValid: Binding<Bool>,
         isPreScanned: Binding<Bool>,
         isInvalidTicket: Binding<Bool>,
         orderName: Binding<String>,
         orderNumber: Binding<String>,
         merchOrderName: Binding<String>,
         merchVariantName: Binding<String>,
         orderDateScanned: Binding<String>,
         invalidMessage: Binding<String>,
         isMerchTicketValid: Binding<Bool>,
         isFullScreen: Binding<Bool>,
         isScanningCell: Binding<Bool>,
         isGoldenTicket: Binding<Bool>,
         isInvalidSeatTicket: Binding<Bool>,
         isInvalidMerchTicket: Binding<Bool>,
         isMerchPreScanned: Binding<Bool>,
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
        _merchOrderName =  merchOrderName
        _merchVariantName =  merchVariantName
        _orderDateScanned = orderDateScanned
        _isMerchTicketValid = isMerchTicketValid
        _isFullScreen = isFullScreen
        _isScanningCell = isScanningCell
        _isGoldenTicket = isGoldenTicket
        _isInvalidSeatTicket = isInvalidSeatTicket
        _isInvalidMerchTicket = isInvalidMerchTicket
        _isMerchPreScanned = isMerchPreScanned
        self.scannerViewModel = scannerViewModel
        self.lookupByOrderResultViewModel = lookupByOrderResultViewModel
        _showOfflineAlert = showOfflineAlert
        _invalidMessage = invalidMessage
    }
    
    // Main view body for the scanner UI, handles camera, overlays, and user interactions
    var body: some View {
            VStack {
                ZStack {
                    // Camera scanner view with scan callback and controller setup
                    CameraScannerView(
                        onScan: { scanned in
                            scannedCode = scanned
                            sendScanRequest(qr: scanned) // Handle scan result
                            resetInactivityTimer()  // Reset inactivity timer on scan
                        },
                        onControllerCreated: { controller in
                            DispatchQueue.main.async {
                                scannerController = controller
                                controller.isScanningBinding = $isScanningCell // Bind scanning state
                            }
                        },
                        isScanning: $isScanningCell  // Bind scanning state
                    ).padding(.bottom, -30)
                        .frame(height: isFullScreen ? nil : scanViewHeight.adaptiveForIpadScan)
                        .frame(maxWidth: .infinity)
                        .onChange(of: isScanning) { newValue in // Start or stop scanning based on state
                            if newValue {
                                scannerController?.startScanning()
                            } else {
                                scannerController?.stopScanning()
                            }
                        }
                    if !isCameraAuthorized {
                        Color.black
                            .frame(height: isFullScreen ? nil : scanViewHeight + 30.adaptiveForIpad)
                            .frame(maxWidth: .infinity)
                            .opacity(1)
                            .padding(.bottom, -30)
                    }
                    // Overlay for full screen ticket/merchandise/invalid views
                    if isFullScreen {
                        VStack {
                            Spacer()
                            if isTicketValid {
                                if isPreScanned {
                                    PreviouslyScannedTicketView(orderName: orderName, orderNumber: orderNumber, scannedTime: orderDateScanned, isInFullScreen: true)
                                } else {
                                    ValidTicketView(orderName: orderName, orderNumber: orderNumber, isGoldenTicket: isGoldenTicket, isInFullScreen: true)
                                }
                            } else if isInvalidTicket {
                                InvalidTicketView(message: invalidMessage, isInFullScreen: true)
                            } /*else if isMerchandiseMode {*/
                            if isMerchPreScanned {
                                PreviousMerchandiseScanView(name: merchOrderName, variantName: merchVariantName, message: orderDateScanned, isInFullScreen: true)
                            }
                            if isMerchTicketValid {
                                MerchandiseScanView(variantName: merchVariantName, name: merchOrderName, isInFullScreen: true)
                            }
                            if isInvalidMerchTicket {
                                InvalidMerchandiseTicketView(isInFullScreen: true)
                            }
                            
                            if isInvalidSeatTicket {
                                InvalidSeatTicketView(message: invalidMessage, isInFullScreen: true)
                            }
                            //                        }
                            Spacer()
                        }.frame(height: isFullScreen ? UIScreen.main.bounds.height * 1 : scanViewHeight)
                            .onAppear {
                                startInactivityTimer()  // Start inactivity timer when overlay appears
                            }
                        AnyView(EmptyView())
                    }
                    VStack {
                        HStack {
                            Text("")
                        }
                        HStack {
                            Spacer()
                            HStack {
                                if isCameraAuthorized {
                                    // Flashlight toggle icon and gesture
                                    Image(isFlashOn ? "FlashOff" : "FlashOn")
                                    .resizable()
                                    .frame(width: 50.adaptiveForIpad, height: 50.adaptiveForIpad)
                                    .padding(.trailing, UIDevice.current.userInterfaceIdiom == .pad ? -50 : -10)
                            }
                            }  .frame(width: dragAreaSize.width, height: dragAreaSize.height)
                                .padding(.top, isFullScreen ? 10 : 10)
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
                        
                        Spacer()
                        
                        // External scanner and scan stats UI
                        HStack {
                            if !isFullScreen {
                                // Button to activate external scanner input
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
                            if !isMerchandiseMode {
                            if showScanStats ?? false {
                                    if let stats = viewModel.stats {
                                        Spacer()
                                        // Display scan statistics
                                        Text("Scanned by Device: \(isOffline ? deviceScanCount : stats.seatsScannedByDevice ?? 0) Scannable Overall: \( stats.seatsScannable ?? 0)")
                                            .font(.verlagBookAdaptive(size: 16))
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                            .padding(.bottom, -30)
                                            .foregroundColor(.white)
                                            .opacity(isVisibleText ? 1 : 0)
                                            .animation(.easeInOut(duration: 0.3), value: isVisibleText)
                                        
                                        Spacer()
                                    }
                                } else {
                                    Spacer()
                                }
                            } else {
                                Spacer()
                            }

                            // Full screen toggle button
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
                    
                      // Overlay for pause scan UI
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
                    
                    // Animated scan line overlay
                    Group {
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
                            }
                        }
                    }
                    .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        isCameraAuthorized = AVCaptureDevice.authorizationStatus(for: .video) == .authorized
                        if isCameraAuthorized {
                            startLineAnimation()
                        }
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
                    Task {
                        await viewModel.fetchStats()
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
                shouldPlayBeepSound = shouldPlayBeep ?? false
                duplicateScanSuppressionNew = duplicateScanSuppression
                withAnimation {
                    isVisibleText = true
                }
//                isTicketValid = true
//                isPreScanned = true
//                isInvalidTicket = true
//                invalidMessage = "Invalid barcode"
//                isMerchTicketValid = true
//                isMerchPreScanned = true
//                merchOrderName = "T-Shirt Variants"
//                merchVariantName = "Medium"
//                orderName = "OrderName"
//                orderNumber = "123456"
//                orderDateScanned = "Previously scanned at @02:15 AM"
//                isInvalidMerchTicket = true
//                isInvalidSeatTicket = true
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
        linePosition = 0
    }
    
    // Computed property to check if any overlay is displayed
    private var isAnyOverlayDisplayed: Bool {
        return (isFullScreen && (isTicketValid || isInvalidTicket || isMerchTicketValid || isPreScanned || isMerchPreScanned || isInvalidSeatTicket || isInvalidMerchTicket))
    }
    
    // Resets the scanner to its initial state
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
    
    
    // Resets the camera view and scanning state
    private func resetCameraView() {
        DispatchQueue.global(qos: .userInitiated).async {
            scannerController?.captureSession?.startRunning()
        }
        DispatchQueue.main.async {
            isCustomColorVisible = false
            isStopScanVisible = false
            scannedCode = nil
            scanResult = nil
            isScanning = true
            isScannerActive = true
            isScanningCell = true
            //        linePosition = 0
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
        var scanType = ""
        var cleanedQR = ""
        if qr.allSatisfy({ $0.isNumber }) {
            // It's a simple numeric barcode
            scanType = "barcode"
            cleanedQR = qr
        }
        // Handle seat QR code
        else if qr.contains("{\"seat\":[") {
            // It's a seat QR code (offline structured format)
            scanType = "seat"
            cleanedQR = qr
                .replacingOccurrences(of: "{\"seat\":[", with: "")
                .replacingOccurrences(of: "]}", with: "")
                .replacingOccurrences(of: "\"", with: "")
        } else if qr.contains("{\"merch\":[") {
            // It's a merchandise QR code (offline structured format)
            scanType = "merch"
            cleanedQR = qr
                .replacingOccurrences(of: "{\"merch\":[", with: "")
                .replacingOccurrences(of: "]}", with: "")
                .replacingOccurrences(of: "\"", with: "")
        } else {
            isInvalidTicket = true
            invalidMessage = "Invalid QR Code"
            playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isInvalidTicket = false
                }
            }
        }
        
        // Extract individual codes (comma-separated QR values)
        let qrCodes = cleanedQR.components(separatedBy: ",").filter { !$0.isEmpty }
        let isMerch = isMerchandise ?? false
        // let scanType = isMerch ? "merch" : "seat"
        guard let qrCode = qrCodes.first else { return }
        
        
        // MARK: - Step 2: Duplicate suppression check
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
        
        // MARK: - Step 3: Offline mode scanning
        if isOfflineMode {
            let separatedQRCodes = qrCodes.joined(separator: "-")
            
            if isMerchandiseMode {
                // Offline merchandise lookup in Core Data
                let fullCode = qrCodes.joined(separator: "-")
                let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "qrCode == %@", fullCode)

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
                            merchOrderName = product.name ?? ""
                            merchVariantName = product.variantName ?? ""

                            isMerchTicketValid = true
                            playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isMerchTicketValid = false
                                }
                            }
                        } else {
                            // ⚠️ Already fully scanned
                            if let scannedTime = product.date_scanned {
                                let formattedDate = MerchandiseOrder.dateFormatter.string(from: scannedTime)
                                showToastMessage("This merchandise was already scanned at \(formattedDate).")
                            } else {
                                showToastMessage("This merchandise has already been fully scanned.")
                            }

                            // Set state to show previous scan view
                            merchOrderName = product.name ?? ""
                            merchVariantName = product.variantName ?? ""
                            if let scannedDate = product.date_scanned {
                                let formattedDate = MerchandiseOrder.dateFormatter.string(from: scannedDate)
                                orderDateScanned = "Previously scanned at \(formattedDate)"
                            }

                            isMerchPreScanned = true
                            playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)

                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isMerchPreScanned = false
                                }
                            }
                        }
                    } else {
                        // ❌ No matching product found
                        isInvalidMerchTicket = true
                        playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isInvalidMerchTicket = false
                            }
                        }
                    }
                } catch {
                    showToastMessage("Database error: \(error.localizedDescription)")
                }
            } else {
                // Offline seat lookup
                let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "qrCode == %@", separatedQRCodes)
                
                do {
                    let results = try viewContext.fetch(fetchRequest)
                    if let seatEntity = results.first {
                        if let scannedTime = seatEntity.date_scanned {
                            // Already scanned seat
                            isPreScanned = true
                            isTicketValid = true
                            orderName = seatEntity.order?.buyerName ?? "Blocked Seat"
                            orderNumber = seatEntity.orderId.map(String.init) ?? "N/A"
                            orderDateScanned = scannedTime.formatted(date: .omitted, time: .shortened)
                            playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isPreScanned = false
                                    isTicketValid = false
                                }
                            }
                        } else {
                            // Mark as scanned
                            seatEntity.locally_scanned += 1
                            deviceScanCount += 1
                            seatEntity.date_scanned = Date()
                            try viewContext.save()
                            isTicketValid = true
                            orderName = seatEntity.order?.buyerName ?? "Blocked Seat"
                            orderNumber = seatEntity.orderId.map(String.init) ?? "N/A"
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
                        // Invalid offline seat QR
                        isInvalidTicket = true
                        invalidMessage = "Invalid Barcode"
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
            // Additional offline barcode check
            if scanType == "barcode" {
                let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "barcode == %@", qr)
                
                do {
                    let results = try viewContext.fetch(fetchRequest)
                    if let seatEntity = results.first {
                        if let scannedTime = seatEntity.date_scanned {
                            isPreScanned = true
                            isTicketValid = true
                            orderName = seatEntity.order?.buyerName ?? "Blocked Ticket"
                            orderNumber = seatEntity.orderId.map(String.init) ?? ""
                            orderDateScanned = scannedTime.formatted(date: .omitted, time: .shortened)
                            playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    isPreScanned = false
                                    isTicketValid = false
                                }
                            }
                        } else {
                            seatEntity.locally_scanned += 1
                            deviceScanCount += 1
                            seatEntity.date_scanned = Date()
                            try viewContext.save()
                            isTicketValid = true
                            orderName = seatEntity.order?.buyerName ?? "Blocked Ticket"
                            orderNumber = seatEntity.orderId.map(String.init) ?? "N/A"
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
                        invalidMessage = "Invalid Barcode"
                        playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isInvalidTicket = false
                            }
                        }
                    }
                } catch {
                    isInvalidTicket = true
                    invalidMessage = "Invalid Barcode"
                    playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            isInvalidTicket = false
                        }
                    }
                }
            }
        } else {
            // MARK: - Step 4: Online mode scanning
            
            // Online seat barcode scan
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
                                        orderName = (responseDict["buyer_name"] as? String)?.capitalized ?? ""
                                        orderNumber = String(responseDict["oid"] as? Int ?? 0)
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
                                    orderName = (responseDict["buyer_name"] as? String)?.capitalized ?? "Blocked Ticket"
                                    orderNumber = String(responseDict["oid"] as? Int ?? 0)
                                    orderDateScanned = responseDict["date_scanned"] as? String ?? ""
                                    isGoldenTicket = (responseDict["is_golden_ticket"] == nil)
                                    playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            isTicketValid = false
                                        }
                                    }
                                    Task {
                                        await viewModel.fetchStats()
                                    }
                                    lastScanTimes[cleanedQR] = now
                                    suppressedOnce.remove(cleanedQR)
                                }
                            }
                        case .failure(let error):
                                    invalidMessage = error.localizedDescription
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
                    // Online merchandise QR scan
                    if scanType == "merch" {
                        IQAPIClient.scanProductQrCode(code: savedShowCode ?? "", qr: qrCodes) { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let responseData):
                                    if let responseDict = responseData as? [String: Any] {
                                        let message = responseDict["message"] as? String ?? ""
                                        let isValid = responseDict["valid"] as? Bool ?? false
                                        
                                        let name = responseDict["name"] as? String ?? ""
                                        let variantName = responseDict["variantName"] as? String ?? ""
                                        
                                        merchOrderName = name
                                        merchVariantName = variantName
                                        orderDateScanned = message

                                        if message.contains("Previously scanned") {
                                            if message.contains("Previously scanned") {
                                                isMerchPreScanned = true
                                                playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)
                                                
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                    withAnimation {
                                                        isMerchPreScanned = false
                                                    }
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
                                        } else {
                                            // ❗ Show error message if valid is false
                                            isInvalidTicket = true
                                            invalidMessage = message
                                            playScanFeedback(beep: shouldPlayBeepSound, haptic: shouldPlayHapticNew)

                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                withAnimation {
                                                    isInvalidTicket = false
                                                }
                                            }
                                        }
                                    }

                                case .failure(let error):
                                    // ❗ Show error if API call failed entirely
                                    isInvalidTicket = true
                                    invalidMessage = error.localizedDescription
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
                        // Offline or wrong scan type
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
                    // Online seat QR scan
                    if scanType == "seat" {
                        IQAPIClient.scanTicketQrCode(code: savedShowCode ?? "", type: scanType, qr: qrCodes) { result in
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
                                                    orderName = scanResponse.buyerName ?? ""
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
                                                    Task {
                                                        await viewModel.fetchStats()
                                                    }
                                                    lastScanTimes[cleanedQR] = now
                                                    suppressedOnce.remove(cleanedQR)
                                                } else if scanResponse.message == "Previously Scanned" {
                                                    isPreScanned = true
                                                    isTicketValid = true
                                                    orderName = scanResponse.buyerName ?? ""
                                                    orderNumber = String(scanResponse.oid ?? 0)
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
                                    
                                case .failure(let error):
                                    invalidMessage = error.localizedDescription
                                       
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
    
    /// Plays feedback for a scan event, such as a beep sound and/or haptic feedback, depending on the provided flags.
    private func playScanFeedback(beep: Bool, haptic: Bool) {
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
