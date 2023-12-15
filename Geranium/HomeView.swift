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
                        LinkCell(imageName: "mypage-icon", url: "https://github.com/c22dev", title: "c22dev")
                        LinkCell(imageName: "lemin", url: "https://github.com/leminlimez", title: "leminlimez (dock hider, various fixes, and passcode themer)")
                        LinkCell(imageName: "sourcelocation", url: "https://github.com/sourcelocation", title: "sourcelocation (Plugins and Tools/AirTroller)")
                    }
                }
                .disabled(true)
            }
        }
        .navigationBarTitle("Geranium")
    }
}

#Preview {
    HomeView()
}
