//
//  GeraniumApp.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI

@main
struct GeraniumApp: App {
    @AppStorage("TSBypass") var tsBypass: Bool = false
    @AppStorage("UPDBypass") var updBypass: Bool = false
    var body: some Scene {
        WindowGroup {
            ContentView(tsBypass: $tsBypass, updBypass: $updBypass)
                .onAppear {
                    if checkSandbox() && !tsBypass{
                        UIApplication.shared.alert(title:"Geranium wasn't installed with TrollStore", body:"Unable to create test file. The app cannot work without the correct entitlements. Please use TrollStore to install it.", withButton:true)
                    }
                    // thanks sourceloc again
                    if !updBypass, let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String, let url = URL(string: "https://api.github.com/repos/c22dev/Geranium/releases/latest") {
                        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                            guard let data = data else { return }
                            
                            if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                if (json["tag_name"] as? String)?.replacingOccurrences(of: "v", with: "").compare(version, options: .numeric) == .orderedDescending {
                                    UIApplication.shared.confirmAlert(title: "Update available", body: "Geranium \(json["tag_name"] as? String ?? "update") is available, do you want to install it (you might need to enable Magnifier URL Scheme in TrollStore Settings)?", onOK: {
                                        UIApplication.shared.open(URL(string: "apple-magnifier://install?url=https://github.com/c22dev/Geranium/releases/download/\(json["tag_name"] as? String ?? "1.0")/Geranium.tipa")!)
                                    }, noCancel: false)
                                }
                            }
                        }
                        task.resume()
                    }
                }
        }
    }
}
