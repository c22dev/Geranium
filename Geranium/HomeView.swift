//
//  HomeView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var isDebugSheetOn = false
    var body: some View {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    homeMainView()
                }
            } else {
                NavigationView {
                    homeMainView()
                }
            }
        }

    @ViewBuilder
    private func homeMainView() -> some View {
        VStack {
            VStack {
                Text("")
                    .padding(.bottom, 20)
                Image(uiImage: Bundle.main.icon!)
                    .cornerRadius(10)
                Text("Geranium")
                    .font(.title2)
                    .bold()
                
                Text("made by c22dev")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                Button("Respring", action: {
                    respring()
                })
                .padding(.bottom, 24)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .frame(maxWidth: .infinity)
            
            ZStack {
                if colorScheme == .dark {
                    Color.black
                        .ignoresSafeArea()
                }
                else {
                    Color.white
                        .ignoresSafeArea()
                }
                Text("")
                List {
                    Section (header: Text("Credits")) {
                        if !isMiniDevice() {
                            LinkCell(imageLink: "https://cclerc.ch/db/geranium/102235607.png", url: "https://github.com/c22dev", title: "c22dev", description: "Main developer")
                        }
                        LinkCell(imageLink: "https://cdn.discordapp.com/avatars/470637062870269952/67eb5d0a0501a96ab0a014ae89027e32.webp?size=160", url: "https://github.com/bomberfish", title: "BomberFish", description: "Daemon Listing")
                        LinkCell(imageLink: "https://cdn.discordapp.com/avatars/412187004407775242/1df69ac879b9e5f98396553eeac80cec.webp?size=160", url: "https://github.com/sourcelocation", title: "sourcelocation", description: "Swift UI Functions")
                        LinkCell(imageLink: "https://cclerc.ch/db/geranium/85764897.png", url: "https://github.com/haxi0", title: "haxi0", description: "Welcome Page source")
                    }
                }
                .disableListScroll()
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isDebugSheetOn.toggle()
                }) {
                    Image(systemName: "hammer")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                }
            }
        }
        .sheet(isPresented: $isDebugSheetOn) {
            SettingsView()
        }
    }
}
