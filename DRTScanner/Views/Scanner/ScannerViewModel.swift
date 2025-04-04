//
//  ScannerViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 20/03/25.
//

import SwiftUI
class ScannerViewModel: ObservableObject {
    @Published var showAlert = false
    @Published var isValidCode = false
    @Published var alertMessage = ""
}
