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
}

struct DaemonView: View {
    @State private var searchText = ""
    @State private var processes: [ProcessItem] = []
    @State private var timer: Timer?
    @State private var toDisable: [String] = []
    @State private var toEnable: [String] = []
    @AppStorage("isDaemonFirstRun") var isDaemonFirstRun: Bool = true

    var filteredProcesses: [ProcessItem] {
        processes.filter {
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
        List {
            SearchBar(text: $searchText)
            
            ForEach(filteredProcesses) { process in
                HStack {
                    Text("PID: \(process.pid)")
                        .foregroundColor(toDisable.contains(process.procName) ? .red : .primary)
                    Spacer()
                    Text("Name: \(process.procName)")
                        .foregroundColor(toDisable.contains(process.procName) ? .red : .primary)
                }
            }
            .onDelete { indexSet in
                guard let index = indexSet.first else { return }
                let process = processes[index]
                
                if let indexToRemove = toDisable.firstIndex(of: process.procName) {
                    toDisable.remove(at: indexToRemove)
                    updateProcesses()
                } else {
                    toDisable.append(process.procName)
                    updateProcesses()
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
                Button(action: {
                    //MARK: Probably the WORST EVER WAY to define a daemon's bundle ID. I'll try over objc s0n
                    for process in toDisable {
                        UIApplication.shared.confirmAlert(title: "Are you sure you want to disable \(process) ?", body: "You can't undo this action. Your phone might bootloop.", onOK: {
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
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
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
                  let procName = dict["proc_name"] as? String else {
                return nil
            }
            return ProcessItem(pid: pid, procName: procName)
        } ?? []
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search...", text: $text)
                .padding(8)
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .padding(.horizontal, 15)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
    }
}

