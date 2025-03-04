//
//  SeatCell.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 11/02/25.
//
//import SwiftUI
//
//struct SeatCell: View {
//    @Binding var seat: SeatModel
//    @State private var isScanned: Bool
//    @State private var scannedTime: String?
//    @State private var isLoading = false
//    
//    init(seat: Binding<SeatModel>) {
//        self._seat = seat
//        self._isScanned = State(initialValue: seat.wrappedValue.scannedTime != nil)
//        if let scannedDate = seat.wrappedValue.scannedTime {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "HH:mm"
//            self._scannedTime = State(initialValue: formatter.string(from: scannedDate))
//        } else {
//            self._scannedTime = State(initialValue: nil)
//        }
//    }
//    
//    private func updateSeatWithScannedQrCode() {
//        guard !isScanned else { return }
//        
//        isLoading = true
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            let currentDate = Date()
//            let formatter = DateFormatter()
//            formatter.dateFormat = "HH:mm"
//            scannedTime = formatter.string(from: currentDate)
//            
//            seat.scannedTime = currentDate
//            isScanned = true
//            isLoading = false
//            
//            saveScannedStatus(for: seat)
//        }
//    }
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Text(isScanned ? "PREVIOUSLY SCANNED AT \(scannedTime ?? "")" : "NOT YET SCANNED")
//                    .font(Font.custom("Verlag-Bold", size: 18))
//                    .foregroundColor(.showCodeText)
//            }
//            HStack(alignment: .center) {
//                HStack(alignment: .bottom, spacing: 0) {
//                    Text("SECT:")
//                        .font(Font.custom("Verlag-Bold", size: 10))
//                        .foregroundColor(.showCodeText)
//                    Text("\(seat.section)")
//                        .font(Font.custom("Verlag-Bold", size: 15))
//                        .foregroundColor(.showCodeText)
//                }
//                Spacer()
//                HStack(alignment: .bottom, spacing: 0) {
//                    Text("ROW:")
//                        .font(Font.custom("Verlag-Bold", size: 10))
//                        .foregroundColor(.showCodeText)
//                    Text("\(seat.row)")
//                        .font(Font.custom("Verlag-Bold", size: 15))
//                        .foregroundColor(.showCodeText)
//                }
//                Spacer()
//                HStack(alignment: .bottom, spacing: 0) {
//                    Text("SEAT:")
//                        .font(Font.custom("Verlag-Bold", size: 10))
//                        .foregroundColor(.showCodeText)
//                    
//                    Text("\(seat.seat)")
//                        .font(Font.custom("Verlag-Bold", size: 15))
//                        .foregroundColor(.showCodeText)
//                }
//                
//                Spacer()
//                if isLoading {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
//                        .scaleEffect(1.0)
//                        .padding(10)
//                } else {
//                    Image(isScanned ? "Green_circle_check_btn" : "scan_now")
//                        .onTapGesture {
//                            updateSeatWithScannedQrCode()
//                        }
//                        .disabled(isScanned)
//                        .opacity(isScanned ? 0.5 : 1.0)
//                }
//            }
//        }
//        .background(Color.customWhite)
//        .padding(0)
//        .onAppear {
//            loadScannedStatus(for: seat)
//        }
//    }
//    
//    private func saveScannedStatus(for seat: SeatModel) {
//        if let scannedDate = seat.scannedTime {
//            UserDefaults.standard.set(scannedDate, forKey: "scanned_\(seat.section)_\(seat.row)_\(seat.seat)")
//        }
//    }
//    
//    private func loadScannedStatus(for seat: SeatModel) {
//        if let savedDate = UserDefaults.standard.object(forKey: "scanned_\(seat.section)_\(seat.row)_\(seat.seat)") as? Date {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "HH:mm"
//            scannedTime = formatter.string(from: savedDate)
//            isScanned = true
//            self.seat.scannedTime = savedDate
//        }
//    }
//}

//import SwiftUI
//import CoreData
//
//struct SeatCell: View {
//    @Binding var seat: SeatModel
//    @State private var seats: Seat?
//    @State private var isScanned: Bool
//    @State private var scannedTime: String?
//    @State private var isLoading = false
//    @Environment(\.managedObjectContext) private var viewContext // Core Data context
//
//    init(seat: Binding<SeatModel>) {
//        self._seat = seat
//        self._isScanned = State(initialValue: seat.wrappedValue.scannedTime != nil)
//        if let scannedDate = seat.wrappedValue.scannedTime {
//            let formatter = DateFormatter()
//            formatter.dateFormat = "HH:mm"
//            self._scannedTime = State(initialValue: formatter.string(from: scannedDate))
//        } else {
//            self._scannedTime = State(initialValue: nil)
//        }
//    }
//
//    private func updateSeatWithScannedQrCode() {
//        guard !isScanned else { return }
//
//        isLoading = true
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            let currentDate = Date()
//            let formatter = DateFormatter()
//            formatter.dateFormat = "HH:mm"
//            scannedTime = formatter.string(from: currentDate)
//
//            seat.scannedTime = currentDate
//            isScanned = true
//            isLoading = false
//
//            // Save the seat model to Core Data
//            saveSeatModelToCoreData(seatModel: seat)
//        }
//    }
//
//    private func saveSeatModelToCoreData(seatModel: SeatModel) {
//        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "barcode == %@", seatModel.qr?.code ?? "")
//
//        do {
//            let results = try viewContext.fetch(fetchRequest)
//            if let coreDataSeat = results.first {
//                // Update existing seat record
//                coreDataSeat.date_scanned = seatModel.scannedTime
//                coreDataSeat.barcode = seatModel.qr?.code
//                coreDataSeat.handicapped = seatModel.qr?.valid == true ? 1 : 0
//                try viewContext.save()
//            } else {
//                let newSeat = Seat(context: viewContext)
//                newSeat.date_scanned = seatModel.scannedTime
//
//                try viewContext.save()
//            }
//        } catch {
//            print("Failed to save Seat to Core Data: \(error.localizedDescription)")
//        }
//    }
//
//    private func fetchSeatModelFromCoreData(barcode: String) {
//        let fetchRequest: NSFetchRequest<Seat> = Seat.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "barcode == %@", barcode)
//
//        do {
//            let results = try viewContext.fetch(fetchRequest)
//            if let coreDataSeat = results.first {
//                var seatModel = SeatModel(
//                    section: coreDataSeat.section ?? "",
//                    row: coreDataSeat.row ?? "",
//                    seat: coreDataSeat.seat ?? "",
//                    qr: Qr(code: coreDataSeat.barcode, valid: coreDataSeat.handicapped?.boolValue),
//                    tsScanned: nil
//                )
//                seatModel.scannedTime = coreDataSeat.date_scanned
//                seat = seatModel
//            }
//        } catch {
//            print("Failed to fetch SeatModel from Core Data: \(error.localizedDescription)")
//        }
//    }
//
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack {
//                Text(isScanned ? "QR SCANNED AT \(scannedTime ?? "")" : "NOT YET SCANNED")
//                    .font(Font.custom("Verlag-Bold", size: 20))
//                    .foregroundColor(.showCodeText)
//            }
//            HStack(alignment: .center) {
//                HStack(alignment: .bottom, spacing: 0) {
//                    Text("SECT:")
//                        .font(Font.custom("Verlag-Bold", size: 10))
//                        .foregroundColor(.showCodeText)
//                    Text("\(seat.section)")
//                        .font(Font.custom("Verlag-Bold", size: 15))
//                        .foregroundColor(.showCodeText)
//                }
//                Spacer()
//                HStack(alignment: .bottom, spacing: 0) {
//                    Text("ROW:")
//                        .font(Font.custom("Verlag-Bold", size: 10))
//                        .foregroundColor(.showCodeText)
//                    Text("\(seat.row)")
//                        .font(Font.custom("Verlag-Bold", size: 15))
//                        .foregroundColor(.showCodeText)
//                }
//                Spacer()
//                HStack(alignment: .bottom, spacing: 0) {
//                    Text("SEAT:")
//                        .font(Font.custom("Verlag-Bold", size: 10))
//                        .foregroundColor(.showCodeText)
//                    
//                    Text("\(seat.seat)")
//                        .font(Font.custom("Verlag-Bold", size: 15))
//                        .foregroundColor(.showCodeText)
//                }
//                
//                Spacer()
//                if isLoading {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
//                        .scaleEffect(1.0)
//                        .padding(10)
//                } else {
//                    Image(isScanned ? "Green_circle_check_btn" : "scan_now")
//                        .onTapGesture {
//                            updateSeatWithScannedQrCode()
//                        }
//                        .disabled(isScanned)
//                        .opacity(isScanned ? 0.5 : 1.0)
//                }
//            }
//        }
//        .background(Color.customWhite)
//        .padding(0)
//        .onAppear {
//            fetchSeatModelFromCoreData(barcode: seat.qr?.code ?? "")
//        }
//    }
//}

import SwiftUI
import CoreData

struct SeatCell: View {
    @Binding var seat: SeatModel
    @State private var isScanned: Bool
    @State private var scannedTime: String?
    @State private var isLoading = false
    @Environment(\.managedObjectContext) private var viewContext
    
    init(seat: Binding<SeatModel>) {
        self._seat = seat
        self._isScanned = State(initialValue: seat.wrappedValue.scannedTime != nil)
        if let scannedDate = seat.wrappedValue.scannedTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "yy-MM-dd-HH:mm:ss"
            self._scannedTime = State(initialValue: formatter.string(from: scannedDate))
        } else {
            self._scannedTime = State(initialValue: nil)
        }
    }
    
    private func updateSeatWithScannedQrCode() {
        guard !isScanned else { return }
        
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yy-MM-dd-HH:mm:ss"
            scannedTime = formatter.string(from: currentDate)
            
            seat.scannedTime = currentDate
            isScanned = true
            isLoading = false
            
            saveScannedStatus(for: seat)
            saveScanData(for: seat, timestamp: currentDate)
        }
    }
    
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
            
            try viewContext.save()
        } catch {
            print("Error saving scanned status: \(error.localizedDescription)")
        }
    }
    
    private func saveScanData(for seat: SeatModel, timestamp: Date) {
        let scanEntity = Scan(context: viewContext)
        scanEntity.qrCode = seat.qrCode
        scanEntity.barcode = seat.barcode
        scanEntity.is_scanned_out = NSNumber(value: true)
        scanEntity.timeStamp = NSNumber(value: timestamp.timeIntervalSince1970)
        
        do {
            try viewContext.save()
        } catch {
            print("Error saving scan data: \(error.localizedDescription)")
        }
    }
    
    private func loadScannedStatus(for seat: SeatModel) {
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

    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(isScanned ? "PREVIOUSLY SCANNED AT \(scannedTime ?? "")" : "NOT YET SCANNED")
                    .font(Font.custom("Verlag-Bold", size: 18))
                    .foregroundColor(.showCodeText)
            }
            HStack(alignment: .center) {
                HStack(alignment: .bottom, spacing: 0) {
                    Text("SECT:")
                        .font(Font.custom("Verlag-Bold", size: 10))
                        .foregroundColor(.showCodeText)
                    Text("\(seat.section)")
                        .font(Font.custom("Verlag-Bold", size: 15))
                        .foregroundColor(.showCodeText)
                }
                Spacer()
                HStack(alignment: .bottom, spacing: 0) {
                    Text("ROW:")
                        .font(Font.custom("Verlag-Bold", size: 10))
                        .foregroundColor(.showCodeText)
                    Text("\(seat.row)")
                        .font(Font.custom("Verlag-Bold", size: 15))
                        .foregroundColor(.showCodeText)
                }
                Spacer()
                HStack(alignment: .bottom, spacing: 0) {
                    Text("SEAT:")
                        .font(Font.custom("Verlag-Bold", size: 10))
                        .foregroundColor(.showCodeText)
                    Text("\(seat.seat)")
                        .font(Font.custom("Verlag-Bold", size: 15))
                        .foregroundColor(.showCodeText)
                }
                
                Spacer()
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                        .scaleEffect(1.0)
                        .padding(10)
                } else {
                    Image(isScanned ? "Green_circle_check_btn" : "scan_now")
                        .onTapGesture {
                            updateSeatWithScannedQrCode()
                        }
                        .disabled(isScanned)
                        .opacity(isScanned ? 0.5 : 1.0)
                }
            }
        }
        .background(Color.customWhite)
        .padding(0)
        .onAppear {
            loadScannedStatus(for: seat)
        }
    }
}
