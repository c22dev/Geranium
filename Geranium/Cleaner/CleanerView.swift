//
// CleanerView.swift
// Geranium
// Created by Constantin Clerc on 10/12/2023.

import SwiftUI

struct CleanerView: View {
    // View Settings
    @State var defaultView: Bool = true
    @State var progressView: Bool = false
    @State var resultView: Bool = false
    
    // User Selection
    @State var safari = false
    @State var appCaches = false
    @State var otaCaches = false
    @State var batteryUsageDat = false
    
    // Sizes
    @State private var safariCacheSize: Double = 0
    @State private var GlobalCacheSize: Double = 0
    @State private var OTACacheSize: Double = 0
    
    // Results
    @State private var progressAmount:CGFloat = 0
    @State var RHResult = ""
    @State var errorDetected: Bool = false
    @State var successDetected: Bool = false
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            // Here we remove NavigationStack for iPads. Why ? Cause pressing "Exit" button with NavigationStack would make a blank screen
            // TODO: Fix .toolbar for iPads
            cleanerViewMain()
        } else {
            NavigationView {
                cleanerViewMain()
            }
        }
    }
    
    @ViewBuilder
    private func cleanerViewMain() -> some View {
        VStack {
            // Default View if nothing is being done
            if defaultView {
                // check if smth is selected
                if safari || appCaches || otaCaches || batteryUsageDat {
                    Button("Clean !", action: {
                        UIApplication.shared.confirmAlert(title: "Selected options", body: "Safari Caches: \(truelyEnabled(safari))\nGeneral Caches: \(truelyEnabled(appCaches))\nOTA Update Caches: \(truelyEnabled(otaCaches))\nBattery Usage Data: \(truelyEnabled(batteryUsageDat))\n Are you sure you want to permanently delete those files ?", onOK: {
                            print("")
                            withAnimation {
                                defaultView.toggle()
                                progressView.toggle()
                            }
                        }, noCancel: false, yes: true)
                    })
                    .padding(10)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .transition(.scale)
                }
                else {
                    Button("Clean !", action: {
                        UIApplication.shared.confirmAlert(title: "Selected options", body: "Safari Caches: \(truelyEnabled(safari))\nGeneral Caches: \(truelyEnabled(appCaches))\nOTA Update Caches: \(truelyEnabled(otaCaches))\nBattery Usage Data: \(truelyEnabled(batteryUsageDat))\n Are you sure you want to permanently delete those files ?", onOK: {
                            print("nothing selected ?")
                        }, noCancel: false, yes: true)
                    })
                    .padding(10)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .transition(.scale)
                    .disabled(true)
                }
                // Normal Toggles
                Toggle(isOn: $safari) {
                    Image(systemName: "safari")
                    Text("Safari Caches")
                    Text("> "+String(format: "%.2f MB", safariCacheSize / (1024 * 1024)))
                }
                .toggleStyle(checkboxiOS())
                .padding(2)
                .onAppear {
                    getSizeForSafariCaches { size in
                        self.safariCacheSize = size
                    }
                }
                Toggle(isOn: $appCaches) {
                    Image(systemName: "app.dashed")
                    Text("General Caches")
                    Text("> " + String(format: "%.2f MB", GlobalCacheSize / (1024 * 1024)))
                }
                .toggleStyle(checkboxiOS())
                .padding(2)
                .onAppear {
                    getSizeForGeneralCaches { size in
                        self.GlobalCacheSize = size
                    }
                }
                
                Toggle(isOn: $otaCaches) {
                    Image(systemName: "restart.circle")
                    Text("OTA Update Caches")
                }
                .toggleStyle(checkboxiOS())
                .padding(2)
                .onAppear {
                    getSizeForOTA { size in
                        self.OTACacheSize = size
                    }
                }
                
                Toggle(isOn: $batteryUsageDat) {
                    Image(systemName: "battery.100percent")
                    Text("Battery Usage Data")
                }
                .toggleStyle(checkboxiOS())
                .padding(2)
            }
            // View being in progress
            else if progressView {
                ProgressBar(value: progressAmount)
                    .padding(.leading, 50)
                    .padding(.trailing, 50)
                    .onAppear {
                        performCleanup()
                    }
            }
            // Success !
            if successDetected, resultView{
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
                    .onAppear {
                        successVibrate()
                    }
                Text("Done !")
                    .foregroundStyle(.green)
                Button("Exit", action: {
                    withAnimation {
                        successDetected.toggle()
                        resultView.toggle()
                        defaultView.toggle()
                    }
                })
                .padding(10)
                .background(.green)
                .cornerRadius(8)
                .foregroundColor(.black)
                .transition(.scale)
            }
            // Error...
            if errorDetected, resultView {
                Image(systemName: "x.circle")
                    .foregroundColor(.red)
                    .onAppear {
                        progressAmount = 0.9
                        errorVibrate()
                    }
                Text("Error !")
                    .foregroundStyle(.red)
                Text("An error occured with the RootHelper.")
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                
                Button("Try again", action: {
                    withAnimation {
                        errorDetected.toggle()
                        resultView.toggle()
                        defaultView.toggle()
                    }
                })
                .padding(10)
                .background(.red)
                .cornerRadius(8)
                .foregroundColor(.black)
                .transition(.scale)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if defaultView {
                    Text("Cleaner")
                        .font(.title2)
                        .bold()
                }
            }
        }
    }
    func performCleanup() {
        cleanProcess(safari: safari, appCaches: appCaches, otaCaches: otaCaches, batteryUsageDat: batteryUsageDat) { progressHandler in
            progressAmount = progressHandler
            if (progressAmount >= 0.9) {
                withAnimation {
                    progressView.toggle()
                    successDetected.toggle()
                    resultView.toggle()
                }
            }
            if (progressAmount < -5) {
                progressAmount = 0
                progressView.toggle()
                errorDetected.toggle()
                resultView.toggle()
            }
        }
    }
}
