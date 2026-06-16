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
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        List {
            Toggle("Enable Tuning", isOn: $flexEnabled)
                .onChange(of: flexEnabled) {
                    GlobalDefaults.write(flexEnabled, forKey: "flexiGlassTuningEnabled")
                    if !flexEnabled {
                        GlobalDefaults.write(nil, forKey: "flexiGlassTuningEnabled")
                    }
                }
            Toggle("Apply to cursor", isOn: $applyCursorValues)
            HStack {
//                Spacer()
                Button("Delete all") {
                    for pref in [
                        "flexiGlassBigGlowOpacity",
                        "flexiGlassLittleGlowOpacity",
                        "flexiGlassLittleGlowDissipationDistance",
                        "flexiGlassLiftScalePoints",
                        "flexiGlassScaleDistanceThreshold",
                        "flexiGlassMovementNormalizationFactor",
                        "flexiGlassMovementScalePoints",
                        "flexiGlassMovementMinScale",
                        "flexiGlassMovementMaxScale",
                        "flexiGlassInteractionPulseNormalizationFactor",
                        "flexiGlassInteractionPulseScalePointsX",
                        "flexiGlassInteractionPulseScalePointsY",
                        "flexiGlassInteractionPulseDriftRatio",
                        "flexiGlassScaleSpringResponse",
                        "flexiGlassScaleSpringDamping",
                        "flexiGlassScaleSpringTrackingResponse",
                        "flexiGlassScaleSpringTrackingDamping",
                    ] {
                        GlobalDefaults.write(nil, forKey: pref)
                        GlobalDefaults.write(nil, forKey: pref.replacingOccurrences(of: "flexiGlass", with: "flexiGlassCursor"))
                    }
                }
                Button("Open Widget Factory") {
                    openWindow(id: "demo")
                }
                .buttonStyle(.glass)
//                Spacer()
            }
            .padding(.vertical, 10)
            .controlSize(.large)
            TuningSlider(key: "flexiGlassBigGlowOpacity", min: 0, defaultValue: 0.5, max: 1, setCursorValues: $applyCursorValues)
            TuningSlider(key: "flexiGlassLittleGlowOpacity", min: 0, defaultValue: 0.6, max: 1, setCursorValues: $applyCursorValues)
            TuningSlider(key: "flexiGlassLittleGlowDissipationDistance", min: 0, defaultValue: 50, max: 200, setCursorValues: $applyCursorValues)
            TuningSlider(key: "flexiGlassLiftScalePoints", min: 0, defaultValue: 10, max: 40, setCursorValues: $applyCursorValues)
            TuningSlider(key: "flexiGlassScaleDistanceThreshold", min: 0, defaultValue: 12, max: 50, setCursorValues: $applyCursorValues)
            Section("Movement") {
                TuningSlider(key: "flexiGlassMovementNormalizationFactor", min: 0, defaultValue: 10, max: 30, setCursorValues: $applyCursorValues)
                TuningSlider(key: "flexiGlassMovementScalePoints", min: 0, defaultValue: 8, max: 40, setCursorValues: $applyCursorValues)
                TuningSlider(key: "flexiGlassMovementMinScale", min: 0, defaultValue: 0.38, max: 1, setCursorValues: $applyCursorValues)
                TuningSlider(key: "flexiGlassMovementMaxScale", min: 0, defaultValue: 0.5, max: 2, setCursorValues: $applyCursorValues)
            }
            Section("Interaction") {
                TuningSlider(key: "flexiGlassInteractionPulseNormalizationFactor", min: 0, defaultValue: 0.3, max: 1, setCursorValues: $applyCursorValues)
                HStack {
                    TuningSlider(key: "flexiGlassInteractionPulseScalePointsX", min: 0, defaultValue: 0.625, max: 2, setCursorValues: $applyCursorValues)
                    TuningSlider(key: "flexiGlassInteractionPulseScalePointsY", min: 0, defaultValue: 1, max: 100, setCursorValues: $applyCursorValues)
                }
                TuningSlider(key: "flexiGlassInteractionPulseDriftRatio", min: 0, defaultValue: 1, max: 30, setCursorValues: $applyCursorValues)
            }
            Section("Spring") {
                TuningSlider(key: "flexiGlassScaleSpringResponse", min: 0, defaultValue: 2, max: 5, setCursorValues: $applyCursorValues)
                TuningSlider(key: "flexiGlassScaleSpringDamping", min: 0, defaultValue: 6.5, max: 100, setCursorValues: $applyCursorValues)
                TuningSlider(key: "flexiGlassScaleSpringTrackingResponse", min: 0, defaultValue: 0.25, max: 2, setCursorValues: $applyCursorValues)
                TuningSlider(key: "flexiGlassScaleSpringTrackingDamping", min: 0, defaultValue: 0.5, max: 2, setCursorValues: $applyCursorValues)
            }
        }
        .toggleStyle(.switch)
        .buttonStyle(.glassProminent)
        .frame(width: 500, height: 600)
    }
}

#Preview {
    ContentView()
}
