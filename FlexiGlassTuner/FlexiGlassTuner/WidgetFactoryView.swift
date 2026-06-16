//
//  WidgetFactoryView.swift
//  FlexiGlassTuner
//
//  Created on 2026-06-16.
//

import SwiftUI

struct WidgetFactoryView: View {
    // global knobs (mirror GTK widget-factory's toolbar)
    @State private var enabled        = true
    @State private var fullWidth      = false
    @State private var controlSize: ControlSize = .regular
    @State private var tint: Color    = .accentColor
    @State private var scheme: ColorScheme? = nil

    // sample state for the controls
    @State private var toggleOn   = true
    @State private var checkOn    = true
    @State private var sliderVal  = 0.5
    @State private var stepperVal = 3
    @State private var progress   = 0.45
    @State private var text       = "Editable text"
    @State private var secure     = "hunter2"
    @State private var pickerSel  = 0
    @State private var segSel     = 0
    @State private var menuSel    = "One"
    @State private var date       = Date()
    @State private var rating     = 3
    @State private var color      = Color.purple

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 20)],
                      alignment: .leading, spacing: 20) {

                group("Buttons") {
                    Button("Standard") {}
                    Button("Bordered") {}.buttonStyle(.bordered)
                    Button("Prominent") {}.buttonStyle(.borderedProminent)
                    Button("Glass") {}.buttonStyle(.glass)
                    Button("Glass Prominent") {}.buttonStyle(.glassProminent)
                    Button("Destructive", role: .destructive) {}.buttonStyle(.bordered)
                    Button { } label: { Label("Icon", systemImage: "star.fill") }
                    Link("Link", destination: URL(string: "https://apple.com")!)
                }

                group("Toggles & Switches") {
                    Toggle("Checkbox", isOn: $checkOn).toggleStyle(.checkbox)
                    Toggle("Switch", isOn: $toggleOn).toggleStyle(.switch)
                    Toggle("Button", isOn: $toggleOn).toggleStyle(.button)
                    Toggle(isOn: $toggleOn) { Label("With Icon", systemImage: "bell") }.toggleStyle(.switch)
                }

                group("Pickers") {
                    Picker("Menu", selection: $menuSel) {
                        ForEach(["One","Two","Three"], id: \.self, content: Text.init)
                    }.pickerStyle(.menu)
                    Picker("Segmented", selection: $segSel) {
                        Text("Day").tag(0); Text("Week").tag(1); Text("Month").tag(2)
                    }.pickerStyle(.segmented)
                    Picker("Radio", selection: $pickerSel) {
                        Text("A").tag(0); Text("B").tag(1); Text("C").tag(2)
                    }.pickerStyle(.radioGroup)
                    ColorPicker("Color", selection: $color)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                group("Value Inputs") {
                    Slider(value: $sliderVal) { Text("Slider") }
                    Slider(value: $sliderVal, in: 0...1, step: 0.1)
                    Stepper("Stepper: \(stepperVal)", value: $stepperVal, in: 0...10)
                    LabeledContent("Gauge") {
                        Gauge(value: progress) { EmptyView() }.gaugeStyle(.accessoryCircularCapacity)
                    }
                }

                group("Text Fields") {
                    TextField("Plain", text: $text).textFieldStyle(.plain)
                    TextField("Rounded", text: $text).textFieldStyle(.roundedBorder)
                    SecureField("Secure", text: $secure)
                    TextEditor(text: $text).frame(height: 56)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.quaternary))
                }

                group("Progress") {
                    ProgressView(value: progress)
                    ProgressView("Determinate", value: progress)
                    ProgressView().controlSize(.small)
                    Gauge(value: progress) { Text("Gauge") }
                }

                group("Indicators & Content") {
                    Label("Label", systemImage: "tag")
                    Image(systemName: "swift").font(.largeTitle).foregroundStyle(tint)
                    HStack { ForEach(0..<5) { i in
                        Image(systemName: i < rating ? "star.fill" : "star")
                            .onTapGesture { rating = i + 1 }
                    }}
                    Text("Body text with **bold** and *italic*.")
                    Divider()
                    ContentUnavailableView("Empty", systemImage: "tray")
                        .frame(height: 90)
                }

                group("Menus") {
                    Menu("Menu") {
                        Button("Action 1") {}
                        Button("Action 2") {}
                        Menu("Submenu") { Button("Nested") {} }
                    }
                    Menu("Pull-down") {
                        Picker("Sort", selection: $pickerSel) {
                            Text("Name").tag(0); Text("Date").tag(1)
                        }
                    }
                }

                group("Disclosure & Containers") {
                    DisclosureGroup("Disclosure") { Text("Hidden content") }
                    GroupBox("GroupBox") { Text("Boxed content") }
                    LabeledContent("Labeled", value: "Detail")
                }
            }
            .padding(20)
            .frame(maxWidth: fullWidth ? .infinity : 920)
            .frame(maxWidth: .infinity)
        }
        .disabled(!enabled)
        .controlSize(controlSize)
        .tint(tint)
        .preferredColorScheme(scheme)
        .toolbar {
            ToolbarItemGroup(placement: .principal) {
                Toggle(isOn: $enabled) { Label("Enabled", systemImage: "power") }
                Toggle(isOn: $fullWidth) { Label("Full Width", systemImage: "arrow.left.and.right") }

                Divider()

                Menu {
                    Picker("Control Size", selection: $controlSize) {
                        Text("Mini").tag(ControlSize.mini)
                        Text("Small").tag(ControlSize.small)
                        Text("Regular").tag(ControlSize.regular)
                        Text("Large").tag(ControlSize.large)
                        Text("XLarge").tag(ControlSize.extraLarge)
                    }
                } label: { Label("Size", systemImage: "textformat.size") }

                ColorPicker("Tint", selection: $tint, supportsOpacity: false)
                    .labelsHidden()

                Divider()

                Button { scheme = .light } label: { Label("Light", systemImage: "sun.max") }
                Button { scheme = .dark }  label: { Label("Dark",  systemImage: "moon") }
                Button { scheme = nil }    label: { Label("Auto",  systemImage: "circle.lefthalf.filled") }
            }
        }
        .toggleStyle(.button)
        .frame(minWidth: 640, minHeight: 520)
    }

    @ViewBuilder
    private func group<C: View>(_ title: String, @ViewBuilder _ content: () -> C) -> some View {
        GroupBox(title) {
            VStack(alignment: .leading, spacing: 12) { content() }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(6)
        }
    }
}

#Preview { WidgetFactoryView() }
