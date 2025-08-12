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
    @EnvironmentObject var stringManager: StringManager
    
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
                            .resizable()
                            .frame(width: 20.adaptiveForIpad, height: 30.adaptiveForIpad, alignment: .center)
                            .foregroundStyle(Color.neutralText)
                            .padding(10.adaptiveForIpad)
                    }
                    Spacer()
                    
                    // Display selected seat (disabled text field)
                    TextField("", text: $viewModel.seatText, prompt: Text(stringManager.strings?.seat.lookUpSeat ?? StringConstants.SeatHomeView.selectSeat)
                        .font(.verlagBoldAdaptive(size: 30))
                        .foregroundColor(.black.opacity(0.2)))
                    .font(.verlagBoldAdaptive(size: 42))
                    .foregroundColor(Color.neutralText)
                    .multilineTextAlignment(.center)
                    .disabled(true)
                    Spacer()
                   
                }
                .padding(.horizontal,15.adaptiveForIpad)
                .frame(maxHeight: 90.adaptiveForIpad)
                .background(Color.neutralBg)
                
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
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.neutralText))
                            .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1)
                    } else {
                        Text(stringManager.strings?.seat.continueField ?? StringConstants.Common.continueText)
                            .font(.verlagBoldAdaptive(size: 36))
                            .foregroundColor(Color.primaryText)
                            .padding(.top, 5.adaptiveForIpad)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.secondaryBg)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 5)
                    }
                }
                .disabled(viewModel.isLoading || viewModel.selectedSeat.isEmpty)
                .opacity(viewModel.selectedSeat.isEmpty ? 0.6 : 1.0)
                .frame(height: geometry.size.height * 0.08)
                .padding(.bottom, UIScreen.main.bounds.height * 0.05)
                .background(Color.primaryText)
                .padding(.horizontal)
            }
            .background(Color.primaryText)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay {
                // Sheet for choosing section
                if isSectionLookupPresented {
                    ChooseSectionView(isPresented: $isSectionLookupPresented, selectedSeat: $viewModel.selectedSection)
                        .transition(.move(edge: .trailing))
                }
           
                // Sheet for choosing row
                if isRowLookupPresented {
                    ChooseRowView(
                        isPresented: $isRowLookupPresented,
                        selectedSeat: $viewModel.selectedRow,
                        selectedSection: $viewModel.selectedSection,
                        selectedRow: $viewModel.selectedRow
                    )
                    .transition(.move(edge: .trailing))
                }
                // Sheet for choosing seat
                if isSeatLookupPresented {
                    ChooseSeatView(
                        isPresented: $isSeatLookupPresented,
                        selectedSeat: $viewModel.selectedSeat,
                        selectedSection: $viewModel.selectedSection,
                        selectedRow: $viewModel.selectedRow
                    )
                    .transition(.move(edge: .trailing))

                }
                // Sheet for displaying lookup result
               if viewModel.showResultView {
                    LookupOrderResultView(
                        inputText: String(viewModel.orderDetails.oid ?? 24241),
                        dismissAction: { viewModel.showResultView = false },
                        errorMessage: viewModel.errorMessage,
                        order: viewModel.order
                    )
                    .transition(.move(edge: .trailing))

                }
            }
        }
    }
}
