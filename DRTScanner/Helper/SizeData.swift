//
//  SizeData.swift
//  DRTScanner
//
//  Created by IE Mac 05 on 01/07/25.
//

import SwiftUI

struct SizeData: Identifiable, Equatable {
    var id: String { "\(size.width)\(size.height)" }
    var isPortrait: Bool { size.width < size.height }
    let size: CGSize
    
    static let empty = SizeData(size: .zero)
    
    static func == (lhs: SizeData, rhs: SizeData) -> Bool {
        return lhs.id == rhs.id
    }
}

// PreferenceKey will help us tracking of the size change and push it
// to EnvironmentKey
struct ReadSizeDataPreferenceKey: PreferenceKey {
    typealias Value = SizeData
    static var defaultValue: SizeData = .empty
    
    static func reduce(value: inout SizeData, nextValue: () -> SizeData) {
        value = nextValue()
    }
}

struct ReadSizeDataEnvironmentKey: EnvironmentKey {
    static let defaultValue: SizeData = .empty
}

extension EnvironmentValues {
    var sizeData: SizeData {
        get { self[ReadSizeDataEnvironmentKey.self] }
        set { self[ReadSizeDataEnvironmentKey.self] = newValue }
    }
}

// Our custom modifier which do all the job
struct ReadSizeData: ViewModifier {
    let sizeData: Binding<SizeData>
    
    func body(content: Content) -> some View {
        content.background {
            GeometryReader { proxy in
                Color.clear.preference(key: ReadSizeDataPreferenceKey.self, value: SizeData(size: proxy.size))
            }
            .onPreferenceChange(ReadSizeDataPreferenceKey.self) { (value) in
                self.sizeData.wrappedValue = value
            }
        }
    }
}

// Custom extension for the nice code look
extension View {
    func readSizeData(_ sizeData: Binding<SizeData>) -> some View {
        return modifier(ReadSizeData(sizeData: sizeData))
    }
}
