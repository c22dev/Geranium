//
//  SettingsView.swift
//  Geranium
//
//  Created by cclerc on 23.12.23.
//

import SwiftUI

struct SettingsView: View {
    @Binding var DebugStuff: Bool
    @Binding var tsBypass: Bool
    @Binding var updBypass: Bool
    @Binding var loggingAllowed: Bool
    var body: some View {
        NavigationView {
            List {
                Section (header: Label("Translators", systemImage: "pencil"), footer: Text("Thanks to all those amazing translators !")) {
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/1108416506716508190/f89568468ab1d14c781f21c7e7ebf183.webp?size=160", url: "https://twitter.com/straight_tamago", title: "Straight Tamago", description: "🇯🇵 Japenese")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/620318902983065606/fe19b5c660b9e8535e884e0fe6c15dbe.webp?size=160", url: "https://twitter.com/straight_tamago", title: "Defflix", description: "🇨🇿/🇸🇰 Czech & Slovak")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/771526460413444096/ce2a56afc2a854eaa99dc27833a63b76.webp?size=160", url: "https://twitter.com/Missauios", title: "iammissa235", description: "🇪🇸 Spanish")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/1183594247929208874/8569adcbd36c70a7578c017bf5604ea5.webp?size=160", url: "https://discordapp.com/users/1183594247929208874", title: "ting0441", description: "🇨🇳 Chinese (Simplified)")
                }
                Section(header: Label("Debug Stuff", systemImage: "chevron.left.forwardslash.chevron.right"), footer: Text("This setting allows you to see experimental values from some app variables.")
                ) {
                    Toggle(isOn: $DebugStuff) {
                        Text("Debug Info")
                    }
                    if DebugStuff {
                        Text("RootHelper Path : \(RootHelper.whatsthePath())")
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            Text("Is the user running an iPad on iPadOS 16 : yes")
                        }
                        else {
                            Text("Is the user running an iPad on iPadOS 16 : no")
                        }
                        Text("Safari Cache Path : \(removeFilePrefix(safariCachePath))")
                    }
                }
                Section(header: Label("Startup Settings", systemImage: "play"), footer: Text("This will personalize app startup pop-ups. Useful for debugging on Simulator or for betas.")
                ) {
                    Toggle(isOn: $tsBypass) {
                        Text("Bypass TrollStore Pop Up")
                    }
                    Toggle(isOn: $updBypass) {
                        Text("Bypass App Update Pop Up")
                    }
                }
                Section(header: Label("Logging Settings", systemImage: "cloud"), footer: Text("We collect some logs that are uploaded to our server for fixing bugs and adressing crash logs. The logs never contains any of your personal information, just your device type and the crash log itself. We also collect measurement information to see what was the most used in the app. You can choose if you want to prevent ANY data from being sent to our server.")
                ) {
                    Toggle(isOn: $loggingAllowed) {
                        Text("Enable logging")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
