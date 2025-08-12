//
//  TimePickerView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 19/02/25.
//

import SwiftUI

struct SelectionView: View {
    @Binding var selectedIndex: IdentifiableIndex?
    var index: Int
    var viewModel: SettingsViewModel
    @State private var selectedValue: Int
    
    init(selectedIndex: Binding<IdentifiableIndex?>, index: Int, viewModel: SettingsViewModel) {
        self._selectedIndex = selectedIndex
        self.index = index
        self.viewModel = viewModel
        
        let initialValue: Int
        switch index {
        case 2:
            initialValue = viewModel.deviceSleepTimeout
        case 3:
            initialValue = viewModel.pauseScanTimeout/10
        case 4:
            initialValue = viewModel.duplicateScanSuppression / 5
        case 5:
            initialValue = {
                switch viewModel.selectedLangText {
                case StringManager.shared.allLangStrings?.enUS.lang ?? "English":
                    return 0
                case StringManager.shared.allLangStrings?.frCA.lang ?? "French":
                    return 1
                case StringManager.shared.allLangStrings?.esUS.lang ?? "Spanish":
                    return 2
                default:
                    return 0
                }
            }()
        default:
            initialValue = 0
        }
        
        self._selectedValue = State(initialValue: initialValue)
    }
    
    var body: some View {
        VStack {
            switch index {
            case 3:
                CustomsText(title: StringManager.shared.strings?.settings.timerInstruction ?? "", textFont: .verlagBookAdaptive(size: 18), foregroundColour: Color.primaryText, alignment: .center)
                    .padding([.top, .horizontal])

            case 4:
                CustomsText(title: StringManager.shared.strings?.settings.duplicateInstruction ?? "", textFont: .verlagBookAdaptive(size: 18), foregroundColour: Color.primaryText, alignment: .center)
                    .padding([.top, .horizontal])
            case 5:
                CustomsText(title: "", textFont: .verlagBookAdaptive(size: 12), foregroundColour: .white)

            default:
                CustomsText(title: StringManager.shared.strings?.settings.duplicateInstruction ?? "", textFont: .verlagBookAdaptive(size: 18), foregroundColour: Color.primaryText, alignment: .center)
                    .padding([.top, .horizontal])
            }
          
            Picker(StringConstants.Common.selectTime, selection: $selectedValue) {
                ForEach(viewModel.getTimeOptions(for: index).indices, id: \.self) { idx in
                    VStack {
                        Text(viewModel.getTimeOptions(for: index)[idx])
                            .font(.pickerBoldText(size: 20))
                            .foregroundColor(Color.primaryText)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                            .tag(idx)
                    }
                }
            }
            .pickerStyle(.wheel)
            .scaleEffect( UIDevice.isIpad ? 1.5 : 1)
            .frame(height: 150.adaptiveForIpad)
            .clipped()
            
            HStack {
          
                Button(action: {
                    selectedIndex = nil
                }) {
                    Text(StringManager.shared.strings?.dialogLogout.cancel ?? StringConstants.Common.cancel)
                        .font(.verlagBoldAdaptive(size: 22))
                        .foregroundColor(Color.primaryBg)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                Spacer()

                Button(action: {
                    viewModel.saveTime(selectedValue, for: index)
                    selectedIndex = nil
                }) {
                    Text(StringManager.shared.strings?.settings.save ?? StringConstants.Common.save)
                        .font(.verlagBoldAdaptive(size: 22))
                        .foregroundColor(Color.primaryBg)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.secondaryBg)
        .cornerRadius(10)
        .padding()
    }
}
