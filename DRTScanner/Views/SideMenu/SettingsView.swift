//
//  SettingsView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var isPresented: Bool
    @AppStorage("isMerchandise") private var isMerchandise: Bool = false
    
    @State private var selectedTimerIndex: IdentifiableIndex?
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("Settings")
                    .font(Font.custom("Verlag-Bold", size: 24))
                    .padding(.leading, 20)
                    .foregroundColor(.white)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image("Popup_cross_btn")
                }
            }.background(Color.FDB_54_E)
            .padding()
            
            List {
                settingsSection
                    .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.FDB_54_E)
            
        } .detectGlobalTaps(disabled: selectedTimerIndex != nil)
        
        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
        .background(Color.FDB_54_E)
        ZStack {
            Color.black.opacity(selectedTimerIndex != nil ? 0.7 : 0)
                .edgesIgnoringSafeArea(.all)
                .animation(.easeInOut(duration: 0.3), value: selectedTimerIndex)
            
            .customSheetView(isPresented: Binding(
                get: { selectedTimerIndex != nil },
                set: { if !$0 { selectedTimerIndex = nil } }
            )) {
                if let index = selectedTimerIndex {
                    TimePickerView(selectedIndex: $selectedTimerIndex, index: index.id, viewModel: viewModel)
                }
            }
        }

    }

    private var settingsSection: some View {
        ForEach(Array(settingItems.enumerated()), id: \.element.title) { index, setting in
            HStack {
                Text(setting.title)
                    .foregroundColor(.white)
                    .font(Font.custom("Verlag-Bold", size: 16))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                if let toggleBinding = setting.toggleBinding {
                    Toggle("", isOn: toggleBinding)
                        .labelsHidden()
                } else {
                    Button(action: { selectedTimerIndex = IdentifiableIndex(id: index) }) {
                        Text(setting.value ?? "")
                            .foregroundColor(.white)
                            .font(Font.custom("Verlag-Bold", size: 16))
                            .padding(8)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 50)
        }
    }

    private var settingItems: [SettingItem] {
        [
            SettingItem(title: "SOUND", toggleBinding: $viewModel.shouldPlayBeep),
            SettingItem(title: "HAPTICS", toggleBinding: $viewModel.shouldPlayHaptic),
            SettingItem(title: "SLEEP TIMER", value: viewModel.deviceSleepTimeoutText),
            SettingItem(title: "SCANNING PAUSE TIMER", value: viewModel.pauseScanTimeoutText),
            SettingItem(title: "DUPLICATE SCAN SUPPRESSION", value: viewModel.duplicateScanSuppressionText),
            SettingItem(title: "SCAN STATS ON SCAN SCREEN", toggleBinding: $viewModel.showScanStats),
            SettingItem(title: "AUTO ENABLE FLASH TIMEOUT", toggleBinding: $viewModel.autoEnableFlashTimeout)
        ]
    }
}

struct SettingItem: Hashable {
    var title: String
    var toggleBinding: Binding<Bool>? = nil
    var value: String? = nil

    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: SettingItem, rhs: SettingItem) -> Bool {
        lhs.title == rhs.title
    }
}

struct IdentifiableIndex: Identifiable, Equatable {
    var id: Int
}
