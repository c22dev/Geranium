//
//  HomeView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI

struct HomeView: View {
    @Binding var tsBypass: Bool
    @Binding var updBypass: Bool
    @Binding var loggingAllowed: Bool
    @Environment(\.colorScheme) var colorScheme
    @State var isDebugSheetOn = false
    @State var DebugStuff = false
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
                
                Text("made by c22dev")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                Button("Respring", action: {
                    respring()
                })
                .padding()
                Button("Rebuild Icon Cache", action: {
                    UIApplication.shared.alert(title:"Rebuilding Icon Cache...", body:"Please wait, your phone until your phone repsrings.", withButton: false)
                    let output = RootHelper.rebuildIconCache()
                    print(output)
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
                        LinkCell(imageLink: "https://avatars.githubusercontent.com/u/85764897?s=160&v=4", url: "https://github.com/haxi0", title: "haxi0")
                    }
                }
                // https://stackoverflow.com/a/75516471
                .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
            }
        }
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
            NavigationView {
                List {
                    Section(header:
                                HStack {
                        Image(systemName: "chevron.left.forwardslash.chevron.right")
                        Text("Debug Stuff")
                    }, footer: Text("This setting allows you to see experimental values from some app variables.")
                    ) {
                        Toggle(isOn: $DebugStuff) {
                            Text("Debug Info")
                        }
                        if DebugStuff {
                            Text("RootHelper Path : \(RootHelper.whatsthePath())")
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                Text("Is the user running an iPad on iPadOS 16 : yes")
                            }
                            else {
                                Text("Is the user running an iPad on iPadOS 16 : no")
                            }
                        }
                    }
                    Section(header:
                                HStack {
                        Image(systemName: "play")
                        Text("Startup Settings")
                    }, footer: Text("This will personalize app startup pop-ups. Useful for debugging on Simulator or for betas.")
                    ) {
                        Toggle(isOn: $tsBypass) {
                            Text("Bypass TrollStore Pop Up")
                        }
                        Toggle(isOn: $updBypass) {
                            Text("Bypass App Update Pop Up")
                        }
                    }
                    Section(header:
                                HStack {
                        Image(systemName: "cloud")
                        Text("Logging Settings")
                    }, footer: Text("We collect some logs that are uploaded to our server for fixing bugs and adressing crash logs. The logs never contains any of your personal information, just your device type and the crash log itself. We also collect measurement information to see what was the most used in the app. You can choose if you want to prevent ANY data from being sent to our server.")
                    ) {
                        Toggle(isOn: $loggingAllowed) {
                            Text("Enable logging")
                        }
                    }
                }
                .navigationTitle("Settings")
            }
        }
    }
}
