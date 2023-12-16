//
//  CleanerView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI

struct CleanerView: View {
    @EnvironmentObject var cleanPaths: CleanPaths
    @State var buttonAndSelection = true
    @State private var safariCacheSize: Double = 0
    @State private var GlobalCacheSize: Double = 0
    @State private var OTACacheSize: Double = 0
    @State private var progressAmount:CGFloat = 0
    @State var safari = false
    @State var appCaches = false
    @State var otaCaches = false
    @State var batteryUsageDat = false
    var body: some View {
        NavigationView {
            VStack {
                if buttonAndSelection {
                    if progressAmount >= 0.9 {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                        Text("Done !")
                            .foregroundStyle(.green)
                        Button("Retry...", action: {
                            withAnimation {
                                progressAmount = 0
                            }
                        })
                        .padding(10)
                        .background(.green)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .transition(.scale)
                    }
                    else {
                        Button("Clean !", action: {
                            UIApplication.shared.confirmAlert(title: "Selected options", body: "Safari Caches: \(truelyEnabled(safari))\n General Caches: \(truelyEnabled(appCaches)))\nOTA Update Caches: \(truelyEnabled(otaCaches))\nBattery Usage Data: \(truelyEnabled(batteryUsageDat))\n Are you sure you want to permanently delete those files ?", onOK: {
                                print("")
                                withAnimation {
                                    buttonAndSelection.toggle()
                                }
                            }, noCancel: false, yes: true)
                        })
                        .padding(10)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .transition(.scale)
                        Toggle(isOn: $safari) {
                            Image(systemName: "safari")
                            Text("Safari Caches")
                            Text(String(format: "%.2f MB", safariCacheSize / (1024 * 1024)))
                        }
                        .toggleStyle(checkboxiOS())
                        .padding(2)
                        .onAppear {
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: cleanPaths.safariCachePath)) { size in
                                safariCacheSize = size
                            }
                        }
                        Toggle(isOn: $appCaches) {
                            Image(systemName: "app.dashed")
                            Text("General Caches")
                            Text(String(format: "%.2f MB", GlobalCacheSize / (1024 * 1024)))
                        }
                        .toggleStyle(checkboxiOS())
                        .padding(2)
                        .onAppear {
                            // mess
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: cleanPaths.logCachesPath)) { size in
                                GlobalCacheSize += size
                            }
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: cleanPaths.logmobileCachesPath)) { size in
                                GlobalCacheSize += size
                            }
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: cleanPaths.tmpCachesPath)) { size in
                                GlobalCacheSize += size
                            }
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: cleanPaths.phototmpCachePath)) { size in
                                GlobalCacheSize += size
                            }
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: cleanPaths.logsCachesPath)) { size in
                                GlobalCacheSize += size
                            }
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: cleanPaths.globalCachesPath)) { size in
                                GlobalCacheSize += size
                            }
                        }
                        
                        Toggle(isOn: $otaCaches) {
                            Image(systemName: "restart.circle")
                            Text("OTA Update Caches")
                            Text(String(format: "%.2f MB", OTACacheSize / (1024 * 1024)))
                        }
                        .toggleStyle(checkboxiOS())
                        .padding(2)
                        .onAppear {
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: cleanPaths.OTAPath)) { size in
                                OTACacheSize = size
                            }
                        }
                        
                        Toggle(isOn: $batteryUsageDat) {
                            Image(systemName: "battery.100percent")
                            Text("Battery Usage Data")
                        }
                        .toggleStyle(checkboxiOS())
                        .padding(2)
                    }
                }
                
                if !buttonAndSelection {
                        ProgressBar(value: progressAmount)
                            .padding(.leading, 50)
                            .padding(.trailing, 50)
                            .onAppear {
//                                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
//                                    self.progressAmount += 0.1
//                                    print(progressAmount)
//                                    if (self.progressAmount >= 0.9) {
//                                        timer.invalidate()
//                                        withAnimation {
//                                            buttonAndSelection.toggle()
//                                            
//                                        }
//                                    }
//                                }
                                performCleanup()
                            }
                }
            }
        }
        .navigationBarTitle("Cleaner")
    }
    func performCleanup() {
        cleanProcess(cleanPaths: cleanPaths, safari: safari, appCaches: appCaches, otaCaches: otaCaches, batteryUsageDat: batteryUsageDat) { progressHandler in
            progressAmount = progressHandler
            if (progressAmount >= 0.9) {
                withAnimation {
                    buttonAndSelection.toggle()
                }
            }
        }
    }
    func calculateDirectorySizeAsync(url: URL, completion: @escaping (Double) -> Void) {
            DispatchQueue.global().async {
                let size = Double(directorySize(url: url))
                DispatchQueue.main.async {
                    completion(size)
                }
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
