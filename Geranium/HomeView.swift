//
//  HomeView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            VStack {
                Text("")
                    .padding(.bottom, 20)
                Image(uiImage: Bundle.main.icon!)
                    .cornerRadius(10)
                Text("Geranium")
                    .font(.title2)
                
                Text("made by c22dev")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                Button("Respring", action: {
                    respring()
                })
                .padding(.bottom, 24)
            }
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
                        LinkCell(imageLink: "https://cdn.discordapp.com/avatars/470637062870269952/67eb5d0a0501a96ab0a014ae89027e32.webp?size=160", url: "https://github.com/bomberfish", title: "BomberFish")
                        LinkCell(imageLink: "https://cdn.discordapp.com/avatars/396496265430695947/0904860dfb31d8b1f39f0e7dc4832b1e.webp?size=160", url: "https://github.com/donato-fiore", title: "fiore")
                        LinkCell(imageLink: "https://cdn.discordapp.com/avatars/412187004407775242/1df69ac879b9e5f98396553eeac80cec.webp?size=160", url: "https://github.com/sourcelocation", title: "sourcelocation")
                    }
                }
                // https://stackoverflow.com/a/75516471
                .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
            }
        }
        .navigationBarTitle("Geranium")
    }
}

#Preview {
    HomeView()
}
