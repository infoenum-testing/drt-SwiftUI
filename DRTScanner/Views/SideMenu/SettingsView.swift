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
        ZStack (alignment: .trailing){
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Text("Settings")
                        .font(.verlagBoldAdaptive(size: 24))
                        .padding(.leading, 10)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(StringConstants.DRTImages.crossImage)
                            .resizable()
                            .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                            .background(Color.clear)
                            .contentShape(Rectangle())
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
            
                .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .leading)
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
                            TimePickerView(selectedIndex: $selectedTimerIndex, index: index.id, viewModel: viewModel).padding(.leading, UIScreen.main.bounds.width * 0.1 )
                        }
                    }
            }
            
        }
    }

    private var settingsSection: some View {
        ForEach(Array(settingItems.enumerated()), id: \.element.title) { index, setting in
            HStack {
                Text(setting.title)
                    .foregroundColor(.white)
                    .font(.verlagBoldAdaptive(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                if let toggleBinding = setting.toggleBinding {
                    Toggle("", isOn: toggleBinding)
                        .labelsHidden()
                        .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.2 : 0.7)
                } else {
                    Button(action: { selectedTimerIndex = IdentifiableIndex(id: index) }) {
                        Text(setting.value ?? "")
                            .foregroundColor(.white)
                            .font(.verlagBoldAdaptive(size: 16))
                            .padding(8)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 50.adaptiveForIpad)
        }
    }

    private var settingItems: [SettingItem] {
        var items: [SettingItem] = [
            SettingItem(title: "SOUND", toggleBinding: $viewModel.shouldPlayBeep),
            SettingItem(title: "HAPTICS", toggleBinding: $viewModel.shouldPlayHaptic),
            SettingItem(title: "SLEEP TIMER", value: viewModel.deviceSleepTimeoutText),
            SettingItem(title: "SCANNING PAUSE TIMER", value: viewModel.pauseScanTimeoutText),
            SettingItem(title: "DUPLICATE SCAN SUPPRESSION", value: viewModel.duplicateScanSuppressionText)
        ]
        
        if !isMerchandise {
            items.append(SettingItem(title: "SCAN STATS ON SCAN SCREEN", toggleBinding: $viewModel.showScanStats))
        }

        items.append(SettingItem(title: "AUTO ENABLE FLASH TIMEOUT", toggleBinding: $viewModel.autoEnableFlashTimeout))
        
        return items
    }

}
