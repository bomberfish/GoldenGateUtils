//
//  TuningSlider.swift
//  FlexiGlassTuner
//
//  Created on 2026-06-15.
//

import SwiftUI

struct TuningSlider: View {
    public var key: String
    public var min: CGFloat
    public var defaultValue: CGFloat
    public var max: CGFloat
    @Binding var setCursorValues: Bool
    
    @State private var internalValue: CGFloat = 0.0
    
    private var cursorKey: String {
        key.replacingOccurrences(of: "flexiGlass", with: "flexiGlassCursor")
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(key.replacingOccurrences(of: "flexiGlass", with: ""))
                    .padding(.leading, 4)
                    .font(.callout)
                
                Spacer()
                HStack {
                    Text(String(describing: internalValue))
                        .fontDesign(.monospaced)
                    Button(action: {
                        GlobalDefaults.write(defaultValue, forKey: key)
                        GlobalDefaults.write(defaultValue, forKey: cursorKey)
                        internalValue = defaultValue
                    }, label: {Image(systemName: "arrow.clockwise")})
                    Button(action: {
                        GlobalDefaults.write(nil, forKey: key)
                        GlobalDefaults.write(nil, forKey: cursorKey)
                        internalValue = defaultValue
                    }, label: {Image(systemName: "trash")})
                }
                .buttonStyle(.plain)
                .font(.caption)
            }
            Slider(value: $internalValue, in: min...max)
                .onChange(of: internalValue) {
                    GlobalDefaults.write(internalValue, forKey: key)
                    GlobalDefaults.write(internalValue, forKey: cursorKey)
                }
        }
        .onAppear {
            internalValue = GlobalDefaults.read(key) as? CGFloat ?? defaultValue
        }
    }
}
//
//#Preview {
//    TuningSlider()
//}
