//
//  CleanerView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI

struct CleanerView: View {
    @State var safari = true
    @State var appCaches = true
    @State var otaCaches = true
    @State var batteryUsageDat = true
    var body: some View {
        NavigationView {
            VStack {
                Button("Clean !", action : {
                    print("")
                })
                .padding(10)
                .background(Color.accentColor)
                .cornerRadius(8)
                .foregroundColor(.black)
                Text("")
                Toggle(isOn: $safari) {
                    Image(systemName: "safari")
                    Text("Safari Caches")
                }
                .toggleStyle(checkboxiOS())
                .padding(2)
                Toggle(isOn: $appCaches) {
                    Image(systemName: "app.dashed")
                    Text("Application Caches")
                }
                .toggleStyle(checkboxiOS())
                .padding(2)
                Toggle(isOn: $otaCaches) {
                    Image(systemName: "restart.circle")
                    Text("OTA Update Caches")
                }
                .toggleStyle(checkboxiOS())
                .padding(2)
                Toggle(isOn: $batteryUsageDat) {
                    Image(systemName:"battery.100percent")
                    Text("Battery Usage Data")
                }
                .toggleStyle(checkboxiOS())
                .padding(2)
            }
            .navigationBarTitle("Cleaner")
        }
    }
}

#Preview {
    CleanerView()
}


// Source : https://sarunw.com/posts/swiftui-checkbox/#swiftui-checkbox-on-ios
struct checkboxiOS: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                configuration.label
            }
        })
    }
}
