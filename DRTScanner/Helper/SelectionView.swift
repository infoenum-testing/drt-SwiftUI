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
            initialValue = viewModel.pauseScanTimeout/10
        case 3:
            initialValue = viewModel.duplicateScanSuppression / 5
        case 4:
            initialValue = {
                let languages = StringManager.allLanguages().map { $0.name }
                if let index = languages.firstIndex(where: {
                    $0.caseInsensitiveCompare(viewModel.selectedLangText) == .orderedSame
                }) {
                    return index
                }
                return 0
            }()
        default:
            initialValue = 0
        }
        
        self._selectedValue = State(initialValue: initialValue)
    }
    
    var body: some View {
        VStack {
            switch index {
            case 2:
                CustomsText(title: StringManager.shared.strings.settings.timerInstructions, textFont: .verlagBookAdaptive(size: 18), foregroundColour: Color.primaryText, alignment: .center)
                    .padding([.top, .horizontal])

            case 3:
                CustomsText(title: StringManager.shared.strings.settings.duplicateInstructions, textFont: .verlagBookAdaptive(size: 18), foregroundColour: Color.primaryText, alignment: .center)
                    .padding([.top, .horizontal])
            case 4:
                CustomsText(title: "", textFont: .verlagBookAdaptive(size: 12), foregroundColour: .white)

            default:
                CustomsText(title: StringManager.shared.strings.settings.duplicateInstructions, textFont: .verlagBookAdaptive(size: 18), foregroundColour: Color.primaryText, alignment: .center)
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
                    Text(StringManager.shared.strings.dialogLogout.cancel)
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
                    Text(StringManager.shared.strings.settings.save)
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
