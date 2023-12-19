//
//  SuperviseView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI

struct SuperviseView: View {
    @State var organisation_name = ""
    @State var plistContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?> <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"> <plist version=\"1.0\"> <dict> <key>AllowPairing</key> <true/> <key>CloudConfigurationUIComplete</key> <true/> <key>ConfigurationSource</key> <integer>0</integer> <key>IsSupervised</key> <true/> <key>PostSetupProfileWasInstalled</key> <true/> </dict> </plist>"
    @State var supervisePath = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/CloudConfigurationDetails.plist"
    var body: some View {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    SuperviseMainView()
                }
            } else {
                NavigationView {
                    SuperviseMainView()
                }
            }
        }
    @ViewBuilder
        private func SuperviseMainView() -> some View {
            VStack {
                TextField("Enter organisation name...", text: $organisation_name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.trailing, 50)
                    .padding(.leading, 50)
                    .padding(.bottom, 10)
                Button("Supervise", action : {
                    print("Attempting to supervise")
                    print("--supervise--")
                    if !organisation_name.isEmpty {
                        print("detected custom orga name")
                        plistContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?> <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"> <plist version=\"1.0\"> <dict> <key>AllowPairing</key> <true/> <key>CloudConfigurationUIComplete</key> <true/> <key>ConfigurationSource</key> <integer>0</integer> <key>IsSupervised</key> <true/> <key>OrganizationName</key> <string>\(organisation_name)</string> <key>PostSetupProfileWasInstalled</key> <true/> </dict> </plist>"
                    }
                    FileManager.default.createFile(atPath: supervisePath, contents: nil)
                    do {
                        try plistContent.write(to: URL(fileURLWithPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/CloudConfigurationDetails.plist"), atomically: true, encoding: .utf8)
                        
                    }
                    catch {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        UIApplication.shared.confirmAlert(title: "Error", body: "We encountered an error while writing to file. Respring anyway ?", onOK: {respring()}, noCancel: false, yes: true)
                    }
                    if !organisation_name.isEmpty {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        UIApplication.shared.confirmAlert(title: "Done !", body: "Your device is now supervised with the custon name \(organisation_name). Please respring now.", onOK: {respring()}, noCancel: true)
                    }
                    else {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        UIApplication.shared.confirmAlert(title: "Done !", body: "Your device is now supervised. Please respring now.", onOK: {respring()}, noCancel: true)
                    }
                })
                .padding(10)
                .background(Color.accentColor)
                .cornerRadius(8)
                .foregroundColor(.black)
                Button("Unsupervise", action : {
                    UIApplication.shared.confirmAlert(title: "Warning", body: "Unsupervising could break some configuration profiles. Are you sure you want to continue ?", onOK: {
                        print("Attempting to unsupervise")
                        FileManager.default.createFile(atPath: supervisePath, contents: nil)
                        plistContent = "<?xml version=\"1.0\" encoding=\"UTF-8\"?> <!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"> <plist version=\"1.0\"> <dict> <key>AllowPairing</key> <true/> <key>CloudConfigurationUIComplete</key> <true/> <key>ConfigurationSource</key> <integer>0</integer> <key>IsSupervised</key> <false/> <key>PostSetupProfileWasInstalled</key> <true/> </dict> </plist>"
                        do {
                            try plistContent.write(to: URL(fileURLWithPath: "/var/containers/Shared/SystemGroup/systemgroup.com.apple.configurationprofiles/Library/ConfigurationProfiles/CloudConfigurationDetails.plist"), atomically: true, encoding: .utf8)
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            UIApplication.shared.confirmAlert(title: "Done !", body: "Please respring your device.", onOK: {respring()}, noCancel: true)
                        }
                        catch {
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            UIApplication.shared.confirmAlert(title: "Error", body: "We encountered an error while writing to file. Respring anyway ?", onOK: {respring()}, noCancel: false, yes: true)
                        }
                    }, noCancel: false)
                })
                .padding(10)
                .background(Color.accentColor)
                .cornerRadius(8)
                .foregroundColor(.black)
                .navigationBarTitle("The Superviser")
            }
    }
}

#Preview {
    SuperviseView()
}
