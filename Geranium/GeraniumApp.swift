//
//  GeraniumApp.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI
@main
struct GeraniumApp: App {
    @State var isInBetaProgram = false // MARK: change this value if the build is Beta
    @StateObject private var appSettings = AppSettings()
    @Environment(\.dismiss) var dismiss
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if checkSandbox(), !appSettings.tsBypass, !appSettings.isFirstRun, isInBetaProgram{
                        UIApplication.shared.alert(title:"Geranium wasn't installed with TrollStore", body:"Unable to create test file. The app cannot work without the correct entitlements. Please use TrollStore to install it.", withButton:true)
                    }
                    
                    if !appSettings.updBypass, let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/c22dev/Geranium/releases/latest") {
                        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                            guard let data = data else { return }
                            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                if (json["tag_name"] as? String)?.replacingOccurrences(of: "v", with: "").compare(version, options: .numeric) == .orderedDescending {
                                    UIApplication.shared.confirmAlert(title: "Update available", body: "Geranium \(json["tag_name"] as? String ?? "update") is available, do you want to install it (you might need to enable Magnifier URL Scheme in TrollStore Settings)?", onOK: {
                                        UIApplication.shared.open(URL(string: "apple-magnifier://install?url=https://github.com/c22dev/Geranium/releases/download/\(json["tag_name"] as? String ?? version)/Geranium.tipa")!)
                                    }, noCancel: false)
                                }
                            }
                        }
                        task.resume()
                    }
                    RootHelper.loadMCM()
                }
                .sheet(isPresented: $appSettings.isFirstRun) {
                    if #available(iOS 16.0, *) {
                        NavigationStack {
                            WelcomeView(loggingAllowed: $appSettings.loggingAllowed, updBypass: $appSettings.updBypass)
                        }
                    } else {
                        NavigationView {
                            WelcomeView(loggingAllowed: $appSettings.loggingAllowed, updBypass: $appSettings.updBypass)
                        }
                    }
                }
                .sheet(isPresented: $isInBetaProgram) {
                    BetaView()
                }
        }
    }
}

class AppSettings: ObservableObject {
    @AppStorage("TSBypass") var tsBypass: Bool = false
    @AppStorage("UPDBypass") var updBypass: Bool = false
    @AppStorage("isLoggingAllowed") var loggingAllowed: Bool = true
    @AppStorage("isFirstRun") var isFirstRun: Bool = true
    @AppStorage("minimSizeC") var minimSizeC: Double = 50.0
    @AppStorage("keepCheckBoxesC") var keepCheckBoxesC: Bool = true
    @AppStorage("LocSimAttempts") var locSimAttemptNB: Int = 1
    @AppStorage("locSimMultipleAttempts") var locSimMultipleAttempts: Bool = false
    @AppStorage("usrUUID") var usrUUID: String = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    @AppStorage("languageCode") var languageCode: String = ""
    @AppStorage("defaultTab") var defaultTab: Int = 1 
}

var langaugee: String = {
    if AppSettings().languageCode.isEmpty {
        return "\(Locale.current.languageCode ?? "en-US")"
    }
    else {
        return "\(Locale.current.languageCode ?? "en")-\(AppSettings().languageCode)"
    }
}()
