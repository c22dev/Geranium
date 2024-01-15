//
//  ByeTimeView.swift
//  Geranium
//
//  Created by cclerc on 29.12.23.
//

import SwiftUI

struct ByeTimeView: View {
    @Binding var DebugStuff: Bool
    @State var ScreenTimeAgent: Bool = true
    @State var usagetrackingd: Bool = true
    @State var homed: Bool = false
    @State var familycircled: Bool = false
    var body: some View {
        VStack {
            List {
                Section(header: Label("Screen Time Agent", systemImage: "hourglass"), footer: Text("Screen Time Agent is responsible for managing all of ScreenTime preferences. Disabling this process only might at best disable Screen Time partially.")) {
                    Toggle(isOn: $ScreenTimeAgent) {
                        Text("Disable Screen Time Agent")
                    }
                    .disabled(!DebugStuff)
                }
                Section(header: Label("Usage Tracking Agent", systemImage: "magnifyingglass"), footer: Text("Usage Tracking Agent monitors and reports usage budgets set by Health, Parental Controls (= Screen Time) or Device Management. Disabling this might also disable some other features on your iPhone.")) {
                    Toggle(isOn: $usagetrackingd) {
                        Text("Disable Usage Tracking Agent")
                    }
                }
                Section(header: Label("Homed", systemImage: "homekit"), footer: Text("Homed is in charge of HomeKit accessories and products, for instance HomePods, connected light bulbs and other, that you are managing from the 'Home' app on your phone. Don't disable this if you are using those accessories.")) {
                    Toggle(isOn: $homed) {
                        Text("Disable Homed")
                    }
                }
                Section(header: Label("Familycircled", systemImage: "figure.and.child.holdinghands"), footer: Text("Familycircled is in charge of iCloud Family system. This includes family subscriptions, so if you disable this you won't be able to use them. However, this can help preventing ScreenTime from working.")) {
                    Toggle(isOn: $familycircled) {
                        Text("Disable Familycircled")
                    }
                }
            }
            Button("Bye ScreenTime !", action : {
                UIApplication.shared.confirmAlert(title: "You are about to disable those daemons.", body: "This will delete Screen Time Preferences files and prevent the following daemoms from starting up with iOS. Are you sure you want to continue ?", onOK: {
                    UIApplication.shared.alert(title: "Removing Screen Time...", body: "Your device will reboot, but I'd recommend you do a manual reboot after the first automatic one.", animated: false, withButton: false)
                    DisableScreenTime(screentimeagentd: ScreenTimeAgent, usagetrackingd: usagetrackingd, homed: homed, familycircled: familycircled)
                }, noCancel: false, yes: true)
            })
            .padding(10)
            .background(Color.accentColor)
            .cornerRadius(8)
            .foregroundColor(.black)
        }
    }
}
