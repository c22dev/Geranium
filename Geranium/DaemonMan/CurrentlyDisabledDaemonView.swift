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
                Section(header: Text("Disabled Daemons Manager"), footer: Text("This is a list of all the currently disabled daemons. Don't change things you didn't changed. The toggled ones are the disabled ones.")) {
                    ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                                        Toggle(isOn: Binding(
                                            get: { data[key] ?? false },
                                            set: { data[key] = $0 }
                                        )) {
                                            Text(key)
                                        }
                    }
                }
                Section(header: Text("Screwed up ?"), footer: Text("Delete currently disabled daemon list, and start-over. iOS will generate the file back from scratch next reboot.")) {
                    Button("Reset") {
                        result = RootHelper.copy(from: URL(fileURLWithPath : "/var/db/com.apple.xpc.launchd/disabled.plist"), to: URL(fileURLWithPath : "/var/mobile/Documents/disabled.gerackup"))
                        result = RootHelper.removeItem(at: URL(fileURLWithPath : "/var/db/com.apple.xpc.launchd/disabled.plist"))
                        result = RootHelper.removeItem(at: URL(fileURLWithPath : "/var/db/com.apple.xpc.launchd/disabled.migrated"))
                    }
                }
            }
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
        var result = RootHelper.removeItem(at: URL(fileURLWithPath: "/var/db/com.apple.xpc.launchd/disabled.plist"))
        print(result)
        result = RootHelper.move(from: URL(fileURLWithPath :"/var/mobile/Documents/disabled.plist"), to: URL(fileURLWithPath: "/var/db/com.apple.xpc.launchd/disabled.plist"))
        print(result)
    }
    func close() {
        dismiss()
    }
}

#Preview {
    CurrentlyDisabledDaemonView()
}
