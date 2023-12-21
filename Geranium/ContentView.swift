//
//  ContentView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var isTabViewHidden = false
    @Binding var tsBypass: Bool
    @Binding var updBypass: Bool
    @Binding var loggingAllowed: Bool
    var body: some View {
        TabView {
            if !isTabViewHidden {
                // TD : USERSPACE REBBOT IMPLEMENTATION
                HomeView(tsBypass: $tsBypass, updBypass: $updBypass, loggingAllowed: $loggingAllowed)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                // TOBEDONE
//                DaemonView()
//                    .tabItem {
//                        Label("Daemons", systemImage: "flag.fill")
//                    } 
                // TOBEFIXED (idk if it actually works ?
                LocSimView()
                    .tabItem {
                        Label("LocSim", systemImage: "mappin")
                    }
                // TOBEDONE
                CleanerView(isTabViewHidden: $isTabViewHidden)
                    .tabItem {
                        Label("Cleaner", systemImage: "trash.fill")
                    }
                SuperviseView()
                    .tabItem {
                        Label("Superviser", systemImage: "checkmark.seal.fill")
                    }
            }
        }
    }
}
