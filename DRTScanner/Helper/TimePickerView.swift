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
    @State private var selectedValue: Int

    init(selectedIndex: Binding<IdentifiableIndex?>, index: Int, viewModel: SettingsViewModel) {
        self._selectedIndex = selectedIndex
        self.index = index
        self.viewModel = viewModel

        switch index {
        case 2: _selectedValue = State(initialValue: viewModel.deviceSleepTimeout)
        case 3: _selectedValue = State(initialValue: viewModel.pauseScanTimeout)
        case 4: _selectedValue = State(initialValue: viewModel.duplicateScanSuppression / 5)
        default: _selectedValue = State(initialValue: 0)
        }
    }

    var body: some View {
        VStack {
            Picker(StringConstants.Common.selectTime, selection: $selectedValue) {
                ForEach(viewModel.getTimeOptions(for: index).indices, id: \.self) { idx in
                    Text(viewModel.getTimeOptions(for: index)[idx])
                        .font(.verlagBoldAdaptive(size: 22))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .tag(idx)
                }
            }
            .pickerStyle(InlinePickerStyle())
            .frame(height: 150.adaptiveForIpad)
            .clipped()
            
            HStack {
                Button(action: {
                    viewModel.saveTime(selectedValue, for: index)
                    selectedIndex = nil
                }) {
                    Text(StringConstants.Common.save)
                        .font(.verlagBoldAdaptive(size: 22))
                        .foregroundColor(.customGreen)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                }
                Spacer()
                Button(action: {
                    selectedIndex = nil
                }) {
                    Text(StringConstants.Common.cancel)
                        .font(.verlagBoldAdaptive(size: 22))
                        .foregroundColor(.customGreen)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.FDB_54_E)
        .padding()
    }
}
