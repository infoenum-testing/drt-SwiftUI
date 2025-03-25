//
//  TimePickerView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//

import SwiftUI

struct TimePickerView: View {
    @Binding var selectedIndex: IdentifiableIndex?
    var index: Int
    var viewModel: SettingsViewModel
    @State private var selectedValue: Int = 0
    
    var body: some View {
        VStack {
            Text("Set Time")
                .font(.title)
            
            Picker("Select Time", selection: $selectedValue) {
                let timeArray = (index == 3 || index == 4 || index == 5) ? viewModel.secArray : viewModel.minArray
                ForEach(0..<timeArray.count, id: \.self) { idx in
                    Text(timeArray[idx])
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            Button("Save") {
                let selectedTime = (index == 3 || index == 4 || index == 5) ? selectedValue : 0
                switch index {
                case 3:
                    viewModel.saveTime(selectedTime, forKey: "kDeviceSleepTimeout")
                case 4:
                    viewModel.saveTime(selectedTime, forKey: "kPauseScanTimeout")
                case 5:
                    viewModel.saveTime(selectedTime, forKey: "kDuplicateScanSuppression")
                default:
                    break
                }
                selectedIndex = nil
            }
            .padding()
        }
        .padding()
    }
}
