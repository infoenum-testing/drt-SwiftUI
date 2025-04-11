//
//  SeatHomeViewModel.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 04/04/25.
//

import Foundation

class SeatHomeViewModel: ObservableObject {
    @Published  var selectedLookupType: LookupType?
    @Published var selectedSeat: SeatModel?
}
