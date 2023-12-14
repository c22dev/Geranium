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
    let processes: [ProcessItem]
    var filteredProcesses: [ProcessItem] {
        processes.filter {
            searchText.isEmpty || $0.procName.localizedCaseInsensitiveContains(searchText)
        }
    }

    init() {
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

    var body: some View {
        NavigationView {
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
                    killall(process.procName)
                    //TODO: FETCH AFTER DELETE
                }
            }
            .navigationTitle("Processes")
        }
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
