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
                Section (header: Label("Translators", systemImage: "pencil"), footer: Text("Thanks to all those amazing translators !")) {
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/640759347240108061/79be8e2ce1557085a6cbb6e58b8d6182.webp?size=160", url: "https://twitter.com/CySxL", title: "CySxL", description: "🇨🇳 Chinese (Traditional)")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/620318902983065606/fe19b5c660b9e8535e884e0fe6c15dbe.webp?size=160", url: "https://twitter.com/Defflix19", title: "Defflix", description: "🇨🇿/🇸🇰 Czech & Slovak")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/984192641170276442/bab37f9fd7fba0b18d5134eae38b9891.webp?size=160", url: "https://twitter.com/dis667_ilya", title: "dis667", description: "🇷🇺 Russian")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/771526460413444096/bb854c50b250e97608452d3c104a324d.webp?size=160", url: "https://twitter.com/Missauios", title: "iammissa235", description: "🇪🇸 Spanish (Latin America)")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/711515258732150795/d4beb5d23d46b0387783cf8be59cdb88.webp?size=160", url: "https://twitter.com/penetranteinc", title: "LeonardoIz", description: "🇪🇸 Spanish / 🇮🇹 Italian / Catalan")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/530721708546588692/e45b6eda6c7127f418d8ec607026bad8.webp?size=160", url: "https://twitter.com/loy64_", title: "Loy64", description: "🇦🇱 Albanian / 🇮🇹 Italian")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/1090613392710062141/187241997651ee575371faa5617d4057.webp?size=160", url: "https://twitter.com/dobabaophuc", title: "Phuc Do", description: "🇻🇳 Vietnamese")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/662843309391216670/4238ed35692fc2ee1df97033b5c76bcc.webp?size=160", url: "https://twitter.com/SAUCECOMPANY_", title: "saucecompany", description: "🇰🇷 Korean")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/766292544765820958/377a1c00e6d6366c10e79d3dfd2f0c8a.webp?size=160", url: "https://twitter.com/speedyfriend67", title: "Speedyfriend67", description: "🇰🇷 Korean")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/607904288882294795/76b2725a7e4f0b1fa18bc2fe4938a846.webp?size=160", url: "https://twitter.com/IshanSharm33634", title: "Spy_G", description: "🇸🇪 Swedish")
                    LinkCell(imageLink: "https://cclerc.ch/db/geranium/dTiW9yol-2.jpg", url: "https://twitter.com/straight_tamago", title: "Straight Tamago", description: "🇯🇵 Japanese")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/1183594247929208874/2bfce82426459ce7f55aeb736fd95a9f.webp?size=160", url: "https://twitter.com/Ting2021", title: "ting0441", description: "🇨🇳 Chinese (Simplified)")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/795556607445696533/4133219a23c5c19fb69f8805bbd04efd.webp?size=160", url: "https://twitter.com/ChromiumCandy", title: "ur.za", description: "🇯🇵 Japanese")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/259867085453131778/685ffaefba4fce61d633f5f5434b7647.webp?size=160", url: "https://twitter.com/Alz971", title: "W$D$B", description: "🇮🇹 Italian")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/709644128685916185/51c2ef8ff5c774f27662753208fa0f67.webp?size=160", url: "https://twitter.com/yyyyyy_public", title: "yyyywaiwai", description: "🇯🇵 Japanese")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
