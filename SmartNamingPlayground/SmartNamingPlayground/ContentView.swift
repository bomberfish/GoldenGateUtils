//
//  ContentView.swift
//  SmartNamingPlayground
//
//  Created on 2026-06-15.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct ContentView: View {
    @State var importing = false
    @State var fileURL: URL?
    
    @State var summary = ""
    @State var content = ""
    @State var location = ""
    @State var date = Date()
    @State var useCustomDate = false
    
    @State var speculative = false
    
    @State var customChildren = ""
    
    @State var isEnabled = SNSmartNameSuggestionsClient.isEnabled()
    
    @State var response: SNNameSuggestionResponse?
    var client = SNSmartNameSuggestionsClient()
    
    @State var inProgress = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                VStack {
                    Group {
                        if !SNSmartNameSuggestionsClient.isAvailable() {
                            Label("SmartNaming is not available!", systemImage: "xmark.circle.fill")
                                .symbolRenderingMode(.multicolor)
                        }
                        else if !isEnabled {
                            HStack {
                                Label("SmartNaming is disabled!", systemImage: "xmark.circle.fill")
                                    .symbolRenderingMode(.multicolor)
                                Spacer()
                                Button("Enable") {
                                    SetNSSmartNamingDisabled(true)
                                    isEnabled = SNSmartNameSuggestionsClient.isEnabled()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .glassEffect(.clear.tint(Color(nsColor: .systemRed).opacity(0.3)))
                }
                Text("""
Quick demo of (ab)using the internal APIs of filename suggestions. 
""")
                .font(.headline)
                HStack {
                    Text("1. The service requires a URL to be passed in.")
                    Spacer()
                    Button("Choose file") {importing.toggle()}
                    if let _ = fileURL {
                        Image(systemName: "checkmark.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color(nsColor: .systemGreen))
                    }
                }
                
                if let fileURL {
                    Text("Selected: \(fileURL.lastPathComponent)")
                }
                
                Text((fileURL?.hasDirectoryPath ?? false) ? "2. Parameters. Directory paths can't really be played with much, the only editable property are the children" : "2. Parameters. Usually it grabs these automatically but they can actually be overriden. Leave them blank to use default values")
                    .padding(.top,10)
                
                Form {
                    if (fileURL?.hasDirectoryPath ?? false) {
                        TextField("Comma-separated children", text: $customChildren)
                    } else {
                        TextField("Text Summary", text: $summary)
                        TextField("Content", text: $content)
                        TextField("Location", text: $location)
                        DatePicker("Creation Date", selection: $date)
                            .onChange(of: date) { _ in
                                useCustomDate = true
                            }
                        Toggle("Use custom date", isOn: $useCustomDate)
                    }
                    Toggle("Speculative", isOn: $speculative)
                        .toggleStyle(.switch)
                        .padding(.top,4)
                }
                
                Spacer()
                HStack {
                    Spacer()
                    if (inProgress) {
                        ProgressView()
                            .controlSize(.small)
                    }
                    Button("Generate!") {
                        Task(priority: .high) {
                            do {
                                inProgress = true
                                //                            var request: SNNameSuggestionRequest?
                                if (fileURL!.hasDirectoryPath) {
                                    print("make directory request")
                                    let request = try SNDirectorySuggestionRequest(url: fileURL!, typeIdentifier: (fileURL!.resourceValues(forKeys: [.contentTypeKey]).contentType ?? .item), speculative: speculative)
                                    request.localeIdentifier = NSLocale.current.identifier
                                    if (!customChildren.isEmpty) {
                                        request.childrenNames = customChildren.components(separatedBy: ",")
                                    }
                                    print("sending request \(request.debugDescription)")
                                    response = try await client.suggestNames(for: request)
                                } else {
                                    print("make file request")
                                    let request = try SNFileSuggestionRequest(url: fileURL!, typeIdentifier: (fileURL!.resourceValues(forKeys: [.contentTypeKey]).contentType ?? .item), speculative: speculative)
                                    request.localeIdentifier = NSLocale.current.identifier
                                    if (!summary.isEmpty) { request.textSummary = summary }
                                    if (!content.isEmpty) { request.textContent = content }
                                    if (!location.isEmpty) { request.locationString = location }
                                    if (useCustomDate) { request.creationDate = date }
                                    print("sending request \(request.debugDescription)")
                                    response = try await client.suggestNames(for: request)
                                }
                                
                                inProgress = false

                                //                            if let request {
                                //
                                //                            } else { throw "what" }
                            } catch {
                                inProgress = false
                                let alert = NSAlert()
                                alert.messageText = "Error"
                                alert.informativeText = error.localizedDescription + "\n" + "\(error)"
                                alert.alertStyle = .critical
                                alert.addButton(withTitle: "OK")
                                await alert.beginSheetModal(for: NSApplication.shared.keyWindow!)
                            }
                        }
                    }
                    .disabled(fileURL == nil || inProgress)
                    .buttonStyle(.glassProminent)
                    .controlSize(.large)
                }
            }
            .padding()
            Divider()
            VStack(alignment: .leading) {
                if let response {
                    let md = """
Suggestions

\(response.suggestions.map { "- \($0)" }.joined(separator: "\n"))
"""
                    Text(LocalizedStringKey("Suggestions\n\n" + response.suggestions.map { "- \($0)" }.joined(separator: "\n")))
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                    Text("Reasoning: \(response.reasoning ?? "none")")
                    Text("Best extension: \(response.bestExtension ?? "none")")
                    Spacer()
                } else {
                    ContentUnavailableView("No Suggestions", systemImage: "siri.gen2", description: Text("Play with the controls on the other side then generate a response"))
                }
            }
            .frame(minWidth: 350, alignment: .leading)
        }
        .fileImporter(isPresented: $importing, allowedContentTypes: [.item]) {
            switch $0 {
            case .success(let url):
                importing.toggle()
                fileURL = url
            case .failure:
                importing.toggle()
                print("cancelled?")
            }
        }
        .frame(minWidth: 800, minHeight: 600, alignment: .topLeading)
    }
}

extension String: @retroactive LocalizedError {
    public var errorDescription: String? { self }
}

#Preview {
    ContentView()
}
