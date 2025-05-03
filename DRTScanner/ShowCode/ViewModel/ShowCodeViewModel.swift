//
//  ShowCodeViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 03/05/25.
//


import SwiftUI

class ShowCodeViewModel: ObservableObject {
    @Published var showCode: String = ""
    @Published var isScannerVisible: Bool = false
    @Published var clickedButton: String? = nil

    var isOKButtonClicked: Bool {
        clickedButton == "OK"
    }

    var isOKButtonEnabled: Bool {
        !showCode.isEmpty
    }

    let buttons = [
        ["A", "B", "C"],
        ["D", "E", "F"],
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        ["-", "0", "OK"]
    ]

    func handleButtonTap(_ button: String, onCodeEntered: @escaping (String) -> Void, dismissSheet: @escaping () -> Void) {
        clickedButton = button

        if button == "OK" {
            if !showCode.isEmpty {
                onCodeEntered(showCode)
                dismissSheet()
            }
        } else {
            showCode.append(button)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.clickedButton = nil
        }
    }

    func removeLastCharacter() {
        if !showCode.isEmpty {
            showCode.removeLast()
        }
    }

    func handleScannedCode(_ code: String, onCodeEntered: (String) -> Void, dismissSheet: () -> Void) {
        onCodeEntered(code)
        isScannerVisible = false
        dismissSheet()
    }
}
