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
                // Top bar with back button and seat text field
                HStack {
                    Button {
                        // Dismiss the SeatLookupView
                        withAnimation(.easeInOut) {
                            isPresented = false
                        }
                    } label: {
                        Image(StringConstants.DRTImages.leftSideArrow)
                    }
                    .padding(.leading, 20)

                    // Display selected seat (disabled text field)
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

                // TableView for selecting section, row, and seat
                TableView(
                    isSeatLookupPresented: $isSeatLookupPresented,
                    isSectionLookupPresented: $isSectionLookupPresented,
                    isRowLookupPresented: $isRowLookupPresented,
                    selectedSection: $viewModel.selectedSection,
                    selectedRow: $viewModel.selectedRow,
                    selectedSeat: $viewModel.selectedSeat
                )
                // Update seat data when selection changes
                .onChange(of: viewModel.selectedSection) { _ in viewModel.onSeatDataChanged() }
                .onChange(of: viewModel.selectedRow) { _ in viewModel.onSeatDataChanged() }
                .onChange(of: viewModel.selectedSeat) { _ in viewModel.onSeatDataChanged() }

                Spacer()
                
                // Continue button to trigger seat lookup
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
        // Sheet for displaying lookup result
        .customSheetView(isPresented: $viewModel.showResultView) {
            LookupOrderResultView(
                inputText: String(viewModel.orderDetails.oid ?? 24241),
                dismissAction: { viewModel.showResultView = false },
                errorMessage: viewModel.errorMessage,
                order: viewModel.order
            )
        }
        // Sheet for choosing seat
        .customSheetView(isPresented: $isSeatLookupPresented) {
            ChooseSeatView(
                isPresented: $isSeatLookupPresented,
                selectedSeat: $viewModel.selectedSeat,
                selectedSection: $viewModel.selectedSection,
                selectedRow: $viewModel.selectedRow
            )
        }
        // Sheet for choosing section
        .customSheetView(isPresented: $isSectionLookupPresented) {
            ChooseSectionView(isPresented: $isSectionLookupPresented, selectedSeat: $viewModel.selectedSection)
        }
        // Sheet for choosing row
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
