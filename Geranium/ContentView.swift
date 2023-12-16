//
//  ContentView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var isTabViewHidden = false
    var body: some View {
        TabView {
            if !isTabViewHidden {
                // TD : USERSPACE REBBOT IMPLEMENTATION
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                // TOBEDONE
                DaemonView()
                    .tabItem {
                        Label("Daemons", systemImage: "flag.fill")
                    } 
                // TOBEFIXED (idk if it actually works ?
                LocationSimulationView()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
