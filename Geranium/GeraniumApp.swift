//
//  GeraniumApp.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI

@main
struct GeraniumApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    if checkSandbox() {
                        UIApplication.shared.alert(title:"Geranium wasn't installed with TrollStore", body:"Unable to create test file. The app cannot work without the correct entitlements. Please use TrollStore to install it.", withButton:true)
                    }
                }
        }
    }
}
