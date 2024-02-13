//
//  WelcomeView.swift
//  Geranium
//
//  Created by cclerc on 19.12.23.
//
// credit to haxi0

import SwiftUI

struct WelcomeView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var loggingAllowed: Bool
    @Binding var updBypass: Bool
    @StateObject private var appSettings = AppSettings()
    var body: some View {
        List {
            Section(header: Text("Setup")) {
                Text("Welcome to Geranium, a toolbox for TrollStore that allows you to disable some daemons, simulate your location, clean your phone's storage and other. We need to configure a few things before you can use the app. This will only take a minute. You will still be able to change the settings later.")
            }
            if getDeviceCode() == "iPhone8,4" {
                Section(header: Text("Hi ! SE 1 User")) {
                    Text("It looks like you are using the app on an iPhone SE 2016 (1st gen). You might encounter serious UI issues. Please excuse me in advance.")
                }
            }
            Section(header: Text("Log Collection")) {
                Text("We collect some logs that are uploaded to our server for fixing bugs and adressing crash logs. The logs never contains any of your personal information, just your device type and the crash log itself. We also collect measurement information to see what was the most used in the app. You can choose if you want to prevent ANY data from being sent to our server.")
                Toggle(isOn: $loggingAllowed) {
                    Text("Enable log collection")
                }
                .onChange(of: loggingAllowed) { newValue in
                    if !loggingAllowed {
                        UIApplication.shared.alert(title: "Warning", body: "Disabling logging might make things more difficult for developers if you have an issue.")
                    }
                }
            }
            
            Section(header: Text("Update Warnings")) {
                Text("When a new update is published, you will receive a pop-up on app launch asking you if you want to update. You can prevent this from hapenning")
                Toggle(isOn: $updBypass) {
                    Text("Disable update pop-up")
                }
            }
            
            Section(header: Text("Cleaner File Sizes")) {
                Text("This is an issue that might incorrectly set permissions when calculating file sizes for your device.")
                Toggle(isOn: $appSettings.getSizes) {
                    Text("Calculate File Size")
                }
            }
            if !updBypass {
                Section(header: Text("WARNING")) {
                    Text("If you want to enable auto-update, you need to turn on Magnifier URL Scheme in TrollStore.")
                    Text("1. Open TrollStore")
                    Text("2. Go to Settings")
                    Text("3. Enable URL Scheme")
                }
            }
        }
        .navigationTitle("Welcome!")
        .navigationBarItems(trailing: Button("Dismiss") {
            close()
        })
        .environment(\.defaultMinListRowHeight, 50)
        .interactiveDismissDisabled()
    }

    func close() {
        dismiss()
    }
}

public struct CustomButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .padding(.vertical, 12)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 14.0, style: .continuous)
                            .fill(Color.accentColor))
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}

public struct LinkButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.body.weight(.medium))
            .padding(.vertical, 12)
            .foregroundColor(.blue)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                            .fill(Color.blue.opacity(0.1)))
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}

public struct DangerButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .padding(.vertical, 12)
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12.0, style: .continuous)
                            .fill(Color.red.opacity(0.1)))
            .opacity(configuration.isPressed ? 0.4 : 1.0)
    }
}
