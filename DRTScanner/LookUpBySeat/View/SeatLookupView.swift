//
//  SeatLookupView.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 13/02/25.
//

import SwiftUI
import SwiftUI

struct SeatLookupView: View {
    @Binding var isPresented: Bool
    @StateObject private var viewModel = SeatLookupViewModel()
    @State private var isSeatLookupPresented = false
    @State private var isSectionLookupPresented = false
    @State private var isRowLookupPresented = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    Button {
                        withAnimation(.easeInOut) {
                            isPresented = false
                        }
                    } label: {
                        Image(StringConstants.DRTImages.leftSideArrow)
                    }
                    .padding(.leading, 20)

                    TextField("", text: $viewModel.seatText, prompt: Text(StringConstants.SeatHomeView.selectSeat)
                        .font(.verlagBoldAdaptive(size: 30))
                        .foregroundColor(.black.opacity(0.2)))
                        .font(.verlagBoldAdaptive(size: 42))
                        .foregroundColor(.customWhite)
                        .multilineTextAlignment(.center)
                        .padding(.leading, -50)
                        .disabled(true)
                }
                .frame(maxHeight: 90.adaptiveForIpad)
                .background(Color.FFCE_62)

                TableView(
                    isSeatLookupPresented: $isSeatLookupPresented,
                    isSectionLookupPresented: $isSectionLookupPresented,
                    isRowLookupPresented: $isRowLookupPresented,
                    selectedSection: $viewModel.selectedSection,
                    selectedRow: $viewModel.selectedRow,
                    selectedSeat: $viewModel.selectedSeat
                )
                .onChange(of: viewModel.selectedSection) { _ in viewModel.onSeatDataChanged() }
                .onChange(of: viewModel.selectedRow) { _ in viewModel.onSeatDataChanged() }
                .onChange(of: viewModel.selectedSeat) { _ in viewModel.onSeatDataChanged() }

                Spacer()
                
                Button {
                    viewModel.continueButtonTapped()
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1)
                    } else {
                        Text(StringConstants.Common.continueText)
                            .font(.verlagBoldAdaptive(size: 36))
                            .foregroundColor(.customWhite)
                            .padding(.top, 5.adaptiveForIpad)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.FFCE_62)
                    }
                }
                .disabled(viewModel.isLoading || viewModel.selectedSeat.isEmpty)
                .opacity(viewModel.selectedSeat.isEmpty ? 0.6 : 1.0)
                .frame(height: geometry.size.height * 0.08)
                .padding(.bottom, UIScreen.main.bounds.height * 0.05)
                .background(Color.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .customSheetView(isPresented: $viewModel.showResultView) {
            LookupOrderResultView(
                inputText: String(viewModel.orderDetails.oid ?? 24241),
                dismissAction: { viewModel.showResultView = false },
                errorMessage: viewModel.errorMessage,
                order: viewModel.order
            )
        }
        .customSheetView(isPresented: $isSeatLookupPresented) {
            ChooseSeatView(
                isPresented: $isSeatLookupPresented,
                selectedSeat: $viewModel.selectedSeat,
                selectedSection: $viewModel.selectedSection,
                selectedRow: $viewModel.selectedRow
            )
        }
        .customSheetView(isPresented: $isSectionLookupPresented) {
            ChooseSectionView(isPresented: $isSectionLookupPresented, selectedSeat: $viewModel.selectedSection)
        }
        .customSheetView(isPresented: $isRowLookupPresented) {
            ChooseRowView(
                isPresented: $isRowLookupPresented,
                selectedSeat: $viewModel.selectedRow,
                selectedSection: $viewModel.selectedSection,
                selectedRow: $viewModel.selectedRow
            )
        }
    }
}
