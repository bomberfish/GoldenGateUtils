//
//  FlexiGlassTunerApp.swift
//  FlexiGlassTuner
//
//  Created on 2026-06-15.
//

import SwiftUI

@main
struct FlexiGlassTunerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        
        Window("Widget Factory", id: "demo") {WidgetFactoryView()}
    }
}
