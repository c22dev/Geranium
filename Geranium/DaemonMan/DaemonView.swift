//
//  DaemonView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI

struct ProcessItem: Identifiable {
    let id = UUID()
    let pid: String
    let procName: String
    let procPath: String
}

struct DaemonView: View {
    @State private var searchText = ""
    @State private var processes: [ProcessItem] = []
    @State private var timer: Timer?
    @State private var toDisable: [String] = []
    @State private var manageSheet: Bool = false
    @State private var processBundle: String = ""
    @State private var isAlphabeticalOrder: Bool = false
    @AppStorage("isDaemonFirstRun") var isDaemonFirstRun: Bool = true

    var filteredProcesses: [ProcessItem] {
        let sortedProcesses = isAlphabeticalOrder ? processes.sorted { $0.procName < $1.procName } : processes
        return sortedProcesses.filter {
            searchText.isEmpty || $0.procName.localizedCaseInsensitiveContains(searchText)
        }
    }

    init() {
        self.processes = []
    }
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
            ForEach(filteredProcesses) { process in
                HStack {
                    Text(process.procName)
                        .foregroundColor(toDisable.contains(process.procName) ? .red : .primary)
                    Spacer()
                    Text("PID: \(process.pid)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .swipeActions {
                    if let existingIndex = toDisable.firstIndex(of: process.procName) {
                        Button(role: .destructive) {
                            toDisable.remove(at: existingIndex)
                            updateProcesses()
                        } label: {
                            Label("Enable", systemImage: "hand.thumbsup")
                        }
                        .tint(.green)
                    }
                    else {
                        Button(role: .destructive) {
                            toDisable.append(process.procName)
                            updateProcesses()
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
                    //MARK: Probably the WORST EVER WAY to define a daemon's bundle ID. I'll try over objc s0n
                    for process in toDisable {
                        processBundle = getDaemonBundleFromPath(path: process)
                        UIApplication.shared.confirmAlert(title: "Are you sure you want to disable \(process) ?", body: "You can undo this action before you reboot by going to the manager icon.", onOK: {
                            daemonManagement(key: "com.apple.\(process)", value: true, plistPath: "/var/db/com.apple.xpc.launchd/disabled.plist")
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
            startTimer()
        }
        .onDisappear {
            stopTimer()
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

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            updateProcesses()
        }
        updateProcesses()
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateProcesses() {
        let rawProcesses = sysctl_ps()
        self.processes = rawProcesses?.compactMap { rawProcess in
            guard let dict = rawProcess as? NSDictionary,
                  let pid = dict["pid"] as? String,
                  let procPath = dict["proc_path"] as? String,
                  let procName = dict["proc_name"] as? String else {
                return nil
            }
            return ProcessItem(pid: pid, procName: procName, procPath: procPath)
        } ?? []
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search a currently running daemon...", text: $text)
                .disableAutocorrection(true)
                .padding(8)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .padding(.horizontal, 15)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

