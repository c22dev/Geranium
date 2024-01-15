//
//  CurrentlyDisabledDaemonView.swift
//  Geranium
//
//  Created by cclerc on 21.12.23.
//

import SwiftUI

struct CurrentlyDisabledDaemonView: View {
    let plistPath = "/var/mobile/Documents/disabled.plist"
    @Environment(\.dismiss) var dismiss
    @State private var data: [String: Bool] = [:]
    @State private var result: String = ""
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Disabled Daemons Manager"), footer: Text("This is a list of all the currently disabled daemons. Swipe to the right to enable back the daemon.")) {
                    ForEach(data.sorted(by: { $0.key < $1.key }).filter { $0.value == true }, id: \.key) { key, _ in
                        Text(key)
                            .swipeActions {
                                Button(role: .destructive) {
                                    removeDaemon(key: key)
                                } label: {
                                    Label("Disable", systemImage: "xmark")
                                }
                            }
                    }
                }
                Section(header: Text("Screwed up ?"), footer: Text("Delete currently disabled daemon list, and start-over. iOS will generate the file back from scratch next reboot.")) {
                    Button("Reset") {
                        result = RootHelper.removeItem(at: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
                        result = RootHelper.copy(from: URL(fileURLWithPath: "/var/db/com.apple.xpc.launchd/disabled.plist"), to: URL(fileURLWithPath: "/var/mobile/Documents/disabled.gerackup"))
                        result = RootHelper.removeItem(at: URL(fileURLWithPath: "/var/db/com.apple.xpc.launchd/disabled.plist"))
                        result = RootHelper.removeItem(at: URL(fileURLWithPath: "/var/db/com.apple.xpc.launchd/disabled.migrated"))
                        data = [:]
                        UIApplication.shared.alert(title:"Done !", body:"Please manually reboot your device", withButton: false)
                    }
                }
            }
            .interactiveDismissDisabled()
            .navigationBarTitle("Manage")
            .navigationBarItems(trailing:
                Button("Save") {
                    saveIt()
                    close()
                }
            )
        }
        .onAppear {
            loadIt()
        }
    }
    private func loadIt() {
        if let dict = NSDictionary(contentsOfFile: plistPath) as? [String: Bool] {
            data = dict
        }
    }
    private func saveIt() {
        (data as NSDictionary).write(toFile: plistPath, atomically: true)
        print(result)
        var result = RootHelper.removeItem(at: URL(fileURLWithPath: "/var/db/com.apple.xpc.launchd/disabled.plist"))
        result = RootHelper.move(from: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"), to: URL(fileURLWithPath: "/var/db/com.apple.xpc.launchd/disabled.plist"))
        print(result)
    }
    
    private func removeDaemon(key: String) {
        data[key] = nil
    }
    
    func close() {
        dismiss()
    }
}

#Preview {
    CurrentlyDisabledDaemonView()
}
