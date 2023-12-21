//
//  DaemonWelcomeView.swift
//  Geranium
//
//  Created by cclerc on 21.12.23.
//

import SwiftUI

struct DaemonWelcomeView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        List {
            
            Section(header: Text("Purpose")) {
                Text("By adding some rules to iOS internals, we prevent the daemon from launching when you boot your phone. The app list every running daemon, and you can swipe left to remove them.")
            }
            
            Section(header: Text("WARNING")) {
                Text("DISABLING SYSTEM DAEMONS IS NOT RECOMMENDED. YOU COULD BOOTLOOP YOUR DEVICE. PROCEED WITH CAUTION. I AM NOT RESPONSIBLE FOR ANY PROBLEM ON YOUR DEVICE.")
                    .foregroundStyle(.red)
            }
            Section(header: Text("Please note")) {
                Text("If you want to revert any of your choice, you should go into the manager (list icon next to the apply icon), where you can toggle disabled daemons.")
                    .foregroundStyle(.green)
            }
        }
        .navigationTitle("Notice")
        .navigationBarItems(trailing: Button("Understood") {
            close()
        })
        .environment(\.defaultMinListRowHeight, 50)
        .interactiveDismissDisabled()
    }

    func close() {
        dismiss()
    }
}

#Preview {
    DaemonWelcomeView()
}
