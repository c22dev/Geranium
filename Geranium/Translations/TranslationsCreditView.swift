//
//  TranslationsCreditView.swift
//  Geranium
//
//  Created by cclerc on 23.12.23.
//

import SwiftUI

struct TranslationsCreditView: View {
    var body: some View {
        VStack {
            List {
                Section (header: Text("Translators"), footer: Text("Thanks to all those amazing translators !")) {
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/1108416506716508190/f89568468ab1d14c781f21c7e7ebf183.webp?size=160", url: "https://twitter.com/straight_tamago", title: "Straight Tamago", description: "🇯🇵 Japenese")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/771526460413444096/ce2a56afc2a854eaa99dc27833a63b76.webp?size=160", url: "https://twitter.com/Missauios", title: "iammissa235", description: "🇪🇸 Spanish")
                    LinkCell(imageLink: "https://cdn.discordapp.com/avatars/1183594247929208874/8569adcbd36c70a7578c017bf5604ea5.webp?size=160", url: "https://discordapp.com/users/1183594247929208874", title: "ting0441", description: "🇨🇳 Chinese (Simplified)")
                }
            }
        }
    }
}

#Preview {
    TranslationsCreditView()
}
