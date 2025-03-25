//
//  SettingsView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//

import SwiftUI


struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var selectedIndex: IdentifiableIndex?
    @Binding var isPresented: Bool
    @AppStorage("isMerchandise") private var isMerchandise: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Settings")
                    .font(Font.custom("Verlag-Bold", size: 30))
                    .foregroundColor(.customWhite)
                    .padding(.leading, 50)
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isPresented = false
                    }
                }) {
                    Image("Popup_cross_btn")
                        .foregroundColor(.black)
                        .padding()
                }
            }
            
            List(viewModel.settingArray.indices, id: \.self) { index in
                HStack {
                    Text(viewModel.settingArray[index])
                        .font(Font.custom("Verlag-Bold", size: 20))
                        .foregroundColor(.customWhite)
                    Spacer()
                    
                    if [0, 1, 5, 6, 7].contains(index) {
                        Toggle("", isOn: Binding(
                            get: { viewModel.getBool(forKey: self.getKey(forRow: index)) },
                            set: { viewModel.setBool($0, forKey: self.getKey(forRow: index)) }
                        ))
                        .labelsHidden()
                    } else if index == 6 { 
                        Toggle("", isOn: $isMerchandise)
                            .hidden()
                    } else {
                        let timeText = self.getTimeText(forRow: index)
                        Text(timeText)
                            .foregroundColor(.customWhite)
                            .onTapGesture {
                                selectedIndex = IdentifiableIndex(id: index)
                            }
                    }
                }
                .padding(8)
                .background(selectedIndex?.id == index ? Color.clear : Color.clear)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
            .background(Color.clear)
            .sheet(item: $selectedIndex) { selectedIndex in
                 TimePickerView(selectedIndex: $selectedIndex, index: selectedIndex.id, viewModel: viewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height)
        .background(Color.FDB_54_E)
    }
    
    func getKey(forRow index: Int) -> String {
        switch index {
        case 0: return "kShouldShowTourOnStartup"
        case 1: return "kShouldPlayBeep"
        case 2: return "kShouldPlayHaptic"
        case 6: return "kShowScanStats"
        case 7: return "kAutoEnableFlashTimeout"
        default: return ""
        }
    }
    
    func getTimeText(forRow index: Int) -> String {
        switch index {
        case 2:
            return viewModel.getTime(forKey: "kDeviceSleepTimeout") == 0 ? "Off" : "\(viewModel.getTime(forKey: "kDeviceSleepTimeout")) mins"
        case 3:
            return viewModel.getTime(forKey: "kPauseScanTimeout") == 0 ? "Off" : "\(viewModel.getTime(forKey: "kPauseScanTimeout")) secs"
        case 4:
            return viewModel.getTime(forKey: "kDuplicateScanSuppression") == 0 ? "Off" : "\(viewModel.getTime(forKey: "kDuplicateScanSuppression")) secs"
        default:
            return "N/A"
        }
    }
}

struct IdentifiableIndex: Identifiable {
    var id: Int
}
