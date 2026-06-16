//
//  ContentView.swift
//  FlexiGlassTuner
//
//  Created on 2026-06-15.
//

import SwiftUI

struct ContentView: View {
    @State var flexEnabled: Bool = false
    @State var applyCursorValues: Bool = true
    
    var body: some View {
        List {
            Toggle("Enable Tuning", isOn: $flexEnabled)
                .onChange(of: flexEnabled) {
                    GlobalDefaults.write(flexEnabled, forKey: "flexiGlassTuningEnabled")
                }
            Toggle("Apply to cursor", isOn: $applyCursorValues)
            TuningSlider(key: "flexiGlassBigGlowOpacity", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
            TuningSlider(key: "flexiGlassLittleGlowOpacity", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
            TuningSlider(key: "flexiGlassLittleGlowDissipationDistance", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
            TuningSlider(key: "flexiGlassLiftScalePoints", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
            TuningSlider(key: "flexiGlassScaleDistanceThreshold", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
            Section("Movement") {
                TuningSlider(key: "flexiGlassMovementNormalizationFactor", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
                TuningSlider(key: "flexiGlassMovementScalePoints", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
                TuningSlider(key: "flexiGlassMovementMinScale", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
                TuningSlider(key: "flexiGlassMovementMaxScale", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
            }
            Section("Interaction") {
                TuningSlider(key: "flexiGlassInteractionPulseNormalizationFactor", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
                HStack {
                    TuningSlider(key: "flexiGlassInteractionPulseScalePointsX", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
                    TuningSlider(key: "flexiGlassInteractionPulseScalePointsY", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
                }
                TuningSlider(key: "flexiGlassInteractionPulseDriftRatio", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
            }
            Section("Spring") {
                TuningSlider(key: "flexiGlassScaleSpringResponse", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
                TuningSlider(key: "flexiGlassScaleSpringDamping", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
                TuningSlider(key: "flexiGlassScaleSpringTrackingResponse", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
                TuningSlider(key: "flexiGlassScaleSpringTrackingDamping", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
            }
        }
        .toggleStyle(.switch)
        .frame(width: 500, height: 600)
    }
}

#Preview {
    ContentView()
}
