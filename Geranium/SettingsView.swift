//
//  SettingsView.swift
//  Geranium
//
//  Created by cclerc on 23.12.23.
//

import SwiftUI
import AlertKit

struct SettingsView: View {
    @State var defaultTab = AppSettings().defaultTab
    @State var DebugStuff: Bool = false
    @State var MinimCal: String = ""
    @State var LocSimTries: String = ""
    @State var localisation: String = {
        if langaugee != "" {
            return langaugee
        }
        else if let languages = UserDefaults.standard.array(forKey: "AppleLanguages") as? [String],
           let firstLanguage = languages.first {
                return "\(Locale.current.languageCode ?? "en-GB")"
        } else {
            return "en-GB"
        }
    }()
    @StateObject private var appSettings = AppSettings()
    
    // Custom language
    @State var appCodeLanguage = langaugee
    let languageMapping: [String: String] = [
        // i made catgpt work for me on this one
                "zh-Hans": "Chinese (Simplified)", //
                "zh-Hant": "Chinese (Traditional)", //
                "Base": "English", //
                "en-GB": "English (GB)",
                "es": "Spanish", //
                "es-419": "Spanish (Latin America)", //
                "fr": "French", //
                "it": "Italian", //
                "ja": "Japanese", //
                "ko": "Korean", //
                "ru": "Russian", //
                "sk": "Slovak", //
                "sv": "Swedish", //
                "vi": "Vietnamese", //
    ]
    var sortedLocalisalist: [String] {
        languageMapping.keys.sorted()
    }
    
    
    // Open Tab
    let defaultTabList: [Int: String] = [
                1: "Home", //
                2: "Daemons", //
                3: "LocSim", //
                4: "Cleaner",
                5: "Superviser", //
    ]
    
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Label("ByeTime", systemImage: "hourglass"), footer: Text("ByeTime allows you to completly disable Screen Time, iCloud or not.")) {
                    NavigationLink(destination: ByeTimeView(DebugStuff: $DebugStuff)) {
                        HStack {
                            Text("ByeTime Settings")
                        }
                    }
                }
                
                Section(header: Label("App Language", systemImage: "magnifyingglass"), footer: Text("Here you can choose in what language you want the app to be. The app will automatically exit to apply changes ; feel free to launch it again.")) {
                    Picker("Language", selection: $localisation) {
                        ForEach(sortedLocalisalist, id: \.self) { abbreviation in
                            Text(languageMapping[abbreviation] ?? abbreviation)
                                .tag(abbreviation)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: localisation) { newValue in
                        if localisation.contains("en-GB") || localisation.contains("zh") || localisation.contains("es-419"){
                            let parts = localisation.components(separatedBy: "-")
                            if let appCodeLanguage = parts.last {
                                print("set custom region: \(appCodeLanguage)")
                                appSettings.languageCode = appCodeLanguage
                                UserDefaults.standard.set(["\(localisation)"], forKey: "AppleLanguages")
                            }
                        }
                        else {
                            print(localisation)
                            appSettings.languageCode = ""
                            UserDefaults.standard.set(["\(newValue)"], forKey: "AppleLanguages")
                        }
                        UIApplication.shared.confirmAlert(title: "You need to quit the app to apply changes.", body: "You might want to open it back.", onOK: {
                            exitGracefully()
                        }, noCancel: true)
                    }
                    .onAppear {
                        print(langaugee)
                        appSettings.languageCode = ""
                    }
                }
                
                
                Section(header: Label("Debug Stuff", systemImage: "chevron.left.forwardslash.chevron.right"), footer: Text("This setting allows you to see experimental values from some app variables.")) {
                    Toggle(isOn: $DebugStuff) {
                        Text("Debug Info")
                    }
                    if DebugStuff {
                        Text("Language set to : \(localisation)")
                        Button("Set language to Default") {
                            UserDefaults.standard.set(["Base"], forKey: "AppleLanguages")
                            UIApplication.shared.confirmAlert(title: "You need to quit the app to apply changes.", body: "You might want to open it back.", onOK: {
                                exitGracefully()
                            }, noCancel: true)
                        }
                        Text("UUID : \(appSettings.usrUUID)")
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
                
                Section(header: Label("Cleaner Settings", systemImage: "trash"), footer: Text("Various settings for the cleaner.")) {
                    Toggle(isOn: $appSettings.keepCheckBoxesC) {
                        Text("Keep selection after cleaning")
                    }
                    Toggle(isOn: $appSettings.getSizes) {
                        Text("Calculate Cleaning Size")
                    }
                    .onChange(of: appSettings.getSizes) { newValue in
                        UIApplication.shared.confirmAlert(title: "You need to quit the app to apply changes.", body: "You might want to open it back.", onOK: {
                            exitGracefully()
                        }, noCancel: true)
                    }
                    Toggle(isOn: Binding<Bool>(
                        get: { !appSettings.tmpClean },
                        set: { appSettings.tmpClean = !$0 }
                    )) {
                        Text("Safe Clean Measures (Enable this if on iOS 15!)")
                    }
                    .onChange(of: appSettings.tmpClean) { newValue in
                        UIApplication.shared.confirmAlert(title: "You need to quit the app to apply changes.", body: "You might want to open it back.", onOK: {
                            exitGracefully()
                        }, noCancel: true)
                    }
                    
                    if DebugStuff {
                        HStack {
                            Text("Minimum Size:")
                            Spacer()
                            TextField("50.0 MB", text: $MinimCal)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: MinimCal) { newValue in
                                    MinimCal = newValue.replacingOccurrences(of: ",", with: ".")
                                }
                        }
                        .onAppear {
                            MinimCal = "\(appSettings.minimSizeC)"
                        }
                        .onChange(of: MinimCal) { newValue in
                            appSettings.minimSizeC = Double(MinimCal) ?? 50.0
                        }
                    }
                }
                Section(header: Label("LocSim Settings", systemImage: "location.fill.viewfinder"), footer: Text("Various settings for LocSim. Sometimes, users can encounter issues with stopping LocSim. Those settings will allow you to attempt to stop LocSim multiple time.")) {
                    Toggle(isOn: $appSettings.locSimMultipleAttempts) {
                        Text("Try stopping LocSim multiple times")
                    }
                    if appSettings.locSimMultipleAttempts {
                        HStack {
                            Text("Minimum Attempts:")
                            Spacer()
                            TextField("3", text: $LocSimTries)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                        .onAppear {
                            LocSimTries = "\(appSettings.locSimAttemptNB)"
                        }
                        .onChange(of: LocSimTries) { newValue in
                            appSettings.locSimAttemptNB = Int(LocSimTries) ?? 1
                        }
                    }
                }
                Section(header: Label("Startup Settings", systemImage: "play"), footer: Text("This will personalize app start-up settings. Useful for debugging on Simulator or for betas.")
                ) {
                    Picker("Default Tab", selection: $defaultTab) {
                        ForEach(Array(defaultTabList.keys).sorted(), id: \.self) { key in
                            Text(defaultTabList[key] ?? "")
                                .tag(key)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: defaultTab) { newValue in
                        print(defaultTab)
                        appSettings.defaultTab = defaultTab
                        print(appSettings.defaultTab)
                        UIApplication.shared.confirmAlert(title: "You need to quit the app to apply changes.", body: "You might want to open it back.", onOK: {
                            exitGracefully()
                        }, noCancel: true)
                    }
                    Toggle(isOn: $appSettings.tsBypass) {
                        Text("Bypass TrollStore Pop Up")
                    }
                    .onChange(of: appSettings.tsBypass) { newValue in
                        AlertKitAPI.present(
                            title: "Saved !",
                            icon: .done,
                            style: .iOS17AppleMusic,
                            haptic: .success
                        )
                    }
                    Toggle(isOn: $appSettings.updBypass) {
                        Text("Bypass App Update Pop Up")
                    }
                    .onChange(of: appSettings.updBypass) { newValue in
                        AlertKitAPI.present(
                            title: "Saved !",
                            icon: .done,
                            style: .iOS17AppleMusic,
                            haptic: .success
                        )
                    }
                    .onChange(of: appSettings.tsBypass) { newValue in
                        AlertKitAPI.present(
                            title: "Saved !",
                            icon: .done,
                            style: .iOS17AppleMusic,
                            haptic: .success
                        )
                    }
                }
                Section(header: Label("App Icon", systemImage: "app"), footer: Text("You can choose and define a custom icon proposed by the community.")
                ) {
                    Button(action: {
                        UIApplication.shared.setAlternateIconName(nil) { error in
                            if let error = error {
                                UIApplication.shared.alert(body:"\(error.localizedDescription)")
                            }
                        }
                    }) {
                        HStack {
                            Image(uiImage: Bundle.main.icon!)
                                .cornerRadius(15)
                                .frame(width: 62.5, height: 62.5)
                            VStack(alignment: .leading) {
                                Text("Default")
                                Text("by c22dev")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    Button(action: {
                        UIApplication.shared.setAlternateIconName("Flore") { error in
                            if let error = error {
                                UIApplication.shared.alert(body:"\(error.localizedDescription)")
                            }
                        }
                    }) {
                        HStack {
                            if let imageURL = URL(string: "https://cclerc.ch/db/geranium/icn/Bouquet.png") {
                                AsyncImageView(url: imageURL)
                                    .cornerRadius(15)
                                    .frame(width: 62.5, height: 62.5)
                            }
                            VStack(alignment: .leading) {
                                Text("Flore")
                                Text("by PhucDo")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    Button(action: {
                        UIApplication.shared.setAlternateIconName("Beta") { error in
                            if let error = error {
                                UIApplication.shared.alert(body:"\(error.localizedDescription)")
                            }
                        }
                    }) {
                        HStack {
                            if let imageURL = URL(string: "https://cclerc.ch/db/geranium/icn/Beta-2.png") {
                                AsyncImageView(url: imageURL)
                                    .cornerRadius(15)
                                    .frame(width: 62.5, height: 62.5)
                            }
                            VStack(alignment: .leading) {
                                Text("Beta")
                                Text("by c22dev")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    Button(action: {
                        UIApplication.shared.setAlternateIconName("Bouquet") { error in
                            if let error = error {
                                UIApplication.shared.alert(body:"\(error.localizedDescription)")
                            }
                        }
                    }) {
                        HStack {
                            if let imageURL = URL(string: "https://cclerc.ch/db/geranium/icn/Flore.png") {
                                AsyncImageView(url: imageURL)
                                    .cornerRadius(15)
                                    .frame(width: 62.5, height: 62.5)
                            }
                            VStack(alignment: .leading) {
                                Text("Suika")
                                Text("by PhucDo")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                Section(header: Label("Logging Settings", systemImage: "cloud"), footer: Text("We collect some logs that are uploaded to our server for fixing bugs and adressing crash logs. The logs never contains any of your personal information, just your device type and the crash log itself. We also collect measurement information to see what was the most used in the app. You can choose if you want to prevent ANY data from being sent to our server.")
                ) {
                    Toggle(isOn: $appSettings.loggingAllowed) {
                        Text("Enable logging")
                    }
                    .onChange(of: appSettings.loggingAllowed) { newValue in
                        if newValue {
                            AlertKitAPI.present(
                                title: "Enabled !",
                                icon: .done,
                                style: .iOS17AppleMusic,
                                haptic: .success
                            )
                        }
                        else {
                            AlertKitAPI.present(
                                title: "Disabled !",
                                icon: .done,
                                style: .iOS17AppleMusic,
                                haptic: .success
                            )
                        }
                    }
                }
                Section (header: Label("Translators", systemImage: "pencil"), footer: Text("Thanks to all those amazing translators !")) {
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/640759347240108061/79be8e2ce1557085a6cbb6e58b8d6182.webp?size=160", url: "https://twitter.com/CySxL", title: "CySxL", description: "🇹🇼 Chinese (Traditional)")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/620318902983065606/fe19b5c660b9e8535e884e0fe6c15dbe.webp?size=160", url: "https://twitter.com/Defflix19", title: "Defflix", description: "🇨🇿/🇸🇰 Czech & Slovak")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/984192641170276442/bab37f9fd7fba0b18d5134eae38b9891.webp?size=160", url: "https://twitter.com/dis667_ilya", title: "dis667", description: "🇷🇺 Russian")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/771526460413444096/bb854c50b250e97608452d3c104a324d.webp?size=160", url: "https://twitter.com/Missauios", title: "iammissa235", description: "🇪🇸 Spanish (Latin America)")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/711515258732150795/d4beb5d23d46b0387783cf8be59cdb88.webp?size=160", url: "https://twitter.com/LeonardoIzzo_", title: "LeonardoIz", description: "🇪🇸 Spanish / 🇮🇹 Italian / Catalan")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/530721708546588692/e45b6eda6c7127f418d8ec607026bad8.webp?size=160", url: "https://twitter.com/loy64_", title: "Loy64", description: "🇦🇱 Albanian / 🇮🇹 Italian")
                    LinkCell(imageLink: "https://i.ibb.co/M53ycZw/pasmoi.webp", url: "https://cclerc.ch/pasmoi.html", title: "PasMoi", description: "🇫🇷 French")
                    LinkCell(imageLink: "https://github.com/olivertzeng.png?size=160", url: "https://github.com/olivertzeng", title: "Oliver Tzeng", description: "🇹🇼 Chinese (Traditional)")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/1090613392710062141/187241997651ee575371faa5617d4057.webp?size=160", url: "https://twitter.com/dobabaophuc", title: "Phuc Do", description: "🇻🇳 Vietnamese")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/662843309391216670/4238ed35692fc2ee1df97033b5c76bcc.webp?size=160", url: "https://twitter.com/SAUCECOMPANY_", title: "saucecompany", description: "🇰🇷 Korean")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/766292544765820958/377a1c00e6d6366c10e79d3dfd2f0c8a.webp?size=160", url: "https://twitter.com/speedyfriend67", title: "Speedyfriend67", description: "🇰🇷 Korean")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/607904288882294795/76b2725a7e4f0b1fa18bc2fe4938a846.webp?size=160", url: "https://twitter.com/spy_g_", title: "Spy_G", description: "🇸🇪 Swedish")
                    LinkCell(imageLink: "https://cclerc.ch/db/geranium/dTiW9yol-2.jpg", url: "https://twitter.com/straight_tamago", title: "Straight Tamago", description: "🇯🇵 Japanese")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/1183594247929208874/2bfce82426459ce7f55aeb736fd95a9f.webp?size=160", url: "https://twitter.com/Ting2021", title: "ting0441", description: "🇨🇳 Chinese (Simplified)")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/259867085453131778/685ffaefba4fce61d633f5f5434b7647.webp?size=160", url: "https://twitter.com/Alz971", title: "W$D$B", description: "🇮🇹 Italian")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/709644128685916185/51c2ef8ff5c774f27662753208fa0f67.webp?size=160", url: "https://twitter.com/yyyyyy_public", title: "yyyywaiwai", description: "🇯🇵 Japanese")
                }
            }
            .navigationTitle("Settings")
        }
    }
}
