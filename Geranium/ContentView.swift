//
//  ContentView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            // TODO: Stability improvements
            DaemonView()
                .tabItem {
                    Label("Daemons", systemImage: "flag.fill")
                }
            LocSimView()
                .tabItem {
                    Label("LocSim", systemImage: "mappin")
                }
            // TODO: Find Battery Usage path
            CleanerView()
                .tabItem {
                    Label("Cleaner", systemImage: "trash.fill")
                }
                .animation(.easeInOut)
            SuperviseView()
                .tabItem {
                    Label("Superviser", systemImage: "checkmark.seal.fill")
                }
        }
    }
}
