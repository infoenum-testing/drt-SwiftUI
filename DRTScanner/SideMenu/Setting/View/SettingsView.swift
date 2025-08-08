//
//  SettingsView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//

import SwiftUI

struct SettingsView: View {
    // ViewModel to manage settings state
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var isPresented: Bool
    @AppStorage("isMerchandise") private var isMerchandise: Bool = false
    
    // State to track which timer index is selected for editing
    @State private var selectedTimerIndex: IdentifiableIndex?
    @EnvironmentObject var stringManager: StringManager
    
    var body: some View {
        ZStack (alignment: .trailing){
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    // Title for the Settings screen
                    Text(stringManager.strings?.settings.settings  ?? StringConstants.SideMenuView.settingSmall)
                        .font(.verlagBoldAdaptive(size: 24))
                        .padding(.leading, 10)
                        .padding(.top, 30)
                        .foregroundColor(Color.primaryText)
                    Spacer()
                    // Button to close the Settings view
                    Button(action: { isPresented = false }) {
                        Image(StringConstants.DRTImages.crossImage)
                            .resizable()
                            .frame(width: 25.adaptiveForIpad, height: 25.adaptiveForIpad)
                            .padding()
                            .background(Color.clear)
                            .contentShape(Rectangle())
                    }
                    .padding(.top, 20)
                }.background(Color.secondaryBg)
                    .padding(.vertical)
                    .padding(.leading)
                
                // List of settings
                List {
                    settingsSection
                        .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.secondaryBg)
            } .detectGlobalTaps(disabled: selectedTimerIndex != nil)
            
                .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .leading)
                .background(Color.secondaryBg)
                .padding(.top, -30)
            // Overlay for time picker modal
            ZStack {
                Color.black.opacity(selectedTimerIndex != nil ? 0.7 : 0)
                    .edgesIgnoringSafeArea(.all)
                    .animation(.easeInOut(duration: 0.3), value: selectedTimerIndex)
                
                    .customSheetView(isPresented: Binding(
                        get: { selectedTimerIndex != nil },
                        set: { if !$0 { selectedTimerIndex = nil } }
                    )) {
                        if let index = selectedTimerIndex {
                            // Time picker for editing timer settings
                            TimePickerView(selectedIndex: $selectedTimerIndex, index: index.id, viewModel: viewModel)
                                .padding(.leading, UIScreen.main.bounds.width * 0.1)
                        }
                    }
            }
            .padding(.top,-30)
            
        }
    }
    
    // Section containing all setting items
    private var settingsSection: some View {
        ForEach(Array(settingItems.enumerated()), id: \.element.title) { index, setting in
            HStack {
                // Setting title
                Text(setting.title)
                    .foregroundColor(Color.primaryText)
                    .font(.verlagBoldAdaptive(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Toggle for boolean settings, button for timer settings
                if let toggleBinding = setting.toggleBinding {
                    Toggle("", isOn: toggleBinding)
                        .labelsHidden()
                        .scaleEffect(UIDevice.current.userInterfaceIdiom == .pad ? 1.5 : 1.0)
                        .padding(10)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleBinding.wrappedValue.toggle()
                        }
                } else {
                    Button(action: { selectedTimerIndex = IdentifiableIndex(id: index) }) {
                        Text(setting.value ?? "")
                            .foregroundColor(Color.primaryText)
                            .font(.verlagBoldAdaptive(size: 16))
                            .padding(8)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 50.adaptiveForIpad)
        }
    }
    
    // Array of all setting items to display
    private var settingItems: [SettingItem] {
        var items: [SettingItem] = [
            SettingItem(title: stringManager.strings?.settings.sound ?? "SOUND", toggleBinding: $viewModel.shouldPlayBeep),
            SettingItem(title: stringManager.strings?.settings.haptics ?? "HAPTICS", toggleBinding: $viewModel.shouldPlayHaptic),
            SettingItem(title: stringManager.strings?.settings.sleepTimer ?? "SLEEP TIMER", value: viewModel.deviceSleepTimeoutText),
            SettingItem(title: stringManager.strings?.settings.timer ?? "SCANNING PAUSE TIMER", value: viewModel.pauseScanTimeoutText),
            SettingItem(title: stringManager.strings?.settings.duplicate ?? "DUPLICATE SCAN SUPPRESSION", value: viewModel.duplicateScanSuppressionText),
            SettingItem(title: stringManager.strings?.settings.language ?? "LANGUAGE", value: viewModel.selectedLangText)
        ]
        
        // Add scan stats toggle if not in Merchandise mode
        if !isMerchandise {
            items.append(SettingItem(title: stringManager.strings?.settings.scanStats ?? "SCAN STATS ON SCAN SCREEN", toggleBinding: $viewModel.showScanStats))
        }
        
        return items
    }
}
