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
                    Spacer()
                    Text("Name: \(process.procName)")
                }
            }
            .onDelete { indexSet in
                guard let index = indexSet.first else { return }
                let process = filteredProcesses[index]
                //MARK: Probably the WORST EVER WAY to define a daemon's bundle ID. I'll try over objc s0n
                daemonManagement(key: "com.apple.\(process.procName)",value: true, plistPath: "/var/db/com.apple.xpc.launchd/disabled.plist")
                killall(process.procName)
                updateProcesses()
                UIApplication.shared.alert(title: "\(process.procName) was successfuly disabled in launchd database", body: "This daemon won't launch next startup.")
            }
        }
        .navigationTitle("Daemons")
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
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

