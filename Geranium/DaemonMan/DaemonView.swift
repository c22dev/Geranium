//
//  DaemonView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI

struct DaemonView: View {
    @State private var searchText = ""
    @State private var daemonFiles: [String] = []
    @State private var labelForDaemon: String?
    @State private var toDisable: [String] = []
    @State private var manageSheet: Bool = false
    @State private var isAlphabeticalOrder: Bool = false
    @AppStorage("isDaemonFirstRun") var isDaemonFirstRun: Bool = true
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                DaemonMainView()
            }
        } else {
            NavigationView {
                DaemonMainView()
            }
        }
    }
    @ViewBuilder
    private func DaemonMainView() -> some View {
        SearchBar(text: $searchText)
        List {
            ForEach(daemonFiles.filter { searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }, id: \.self) { fileName in
                HStack {
                    Text(fileName)
                        .foregroundColor(toDisable.contains(getLabel(fileName) ?? fileName) ? .red : .primary)
                    Spacer()
                }
                .swipeActions {
                    if let existingIndex = toDisable.firstIndex(of: fileName) {
                        Button(role: .destructive) {
                            labelForDaemon = getLabel(fileName)
                            toDisable.remove(at: existingIndex)
                        } label: {
                            Label("Enable", systemImage: "hand.thumbsup")
                        }
                        .tint(.green)
                    }
                    else {
                        Button(role: .destructive) {
                            labelForDaemon = getLabel(fileName)
                            toDisable.append(labelForDaemon ?? fileName)
                        } label: {
                            Label("Disable", systemImage: "hand.thumbsdown")
                        }
                    }
                }
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Daemons")
                    .font(.title2)
                    .bold()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Toggle(isOn: $isAlphabeticalOrder) {
                    Label("Alphabetical", systemImage: "textformat")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    var error = RootHelper.copy(from: URL(fileURLWithPath: "/var/db/com.apple.xpc.launchd/disabled.plist"), to: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
                    print(error)
                    error = RootHelper.setPermission(url: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
                    manageSheet.toggle()
                }) {
                    Image(systemName: "list.bullet")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    for process in toDisable {
                        UIApplication.shared.confirmAlert(title: "Are you sure you want to disable \(process) ?", body: "You can still undo this action after by going to the manager icon.", onOK: {
                            daemonManagement(key: process, value: true, plistPath: "/var/db/com.apple.xpc.launchd/disabled.plist")
                        }, noCancel: false)
                    }
                    if toDisable == [] {
                        UIApplication.shared.alert(title: "You didn't select any daemon", body: "Please swipe a running daemon to the left to disable it.")
                    }
                }) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
        }
        .onAppear {
            updateDaemonFiles()
        }
        .sheet(isPresented: $isDaemonFirstRun) {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    DaemonWelcomeView()
                }
            } else {
                NavigationView {
                    DaemonWelcomeView()
                }
            }
        }
        .sheet(isPresented:$manageSheet) {
            CurrentlyDisabledDaemonView()
        }
    }
    
    private func updateDaemonFiles() {
        let launchDaemonsURL = URL(fileURLWithPath: "/System/Library/LaunchDaemons/")
        do {
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(atPath: launchDaemonsURL.path)
            daemonFiles = files.map { URL(fileURLWithPath: $0).deletingPathExtension().lastPathComponent }
        } catch {
            UIApplication.shared.alert(body: "error reading LaunchDaemons directory: \(error)")
        }
    }
    private func getLabel(_ fileName: String) -> String? {
        let plistURL = URL(fileURLWithPath: "/System/Library/LaunchDaemons/\(fileName).plist")
        do {
            let data = try Data(contentsOf: plistURL)
            let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
            if let dict = plist as? [String: Any], let label = dict["Label"] as? String {
                return label
            }
        } catch {
            UIApplication.shared.alert(body: "Error reading plist: \(error)")
        }
        return nil
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search for a daemon...", text: $text)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .padding(8)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .padding(.horizontal, 15)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

