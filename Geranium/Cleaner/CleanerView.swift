//
//  CleanerView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI


struct CleanerView: View {
    @Binding var isTabViewHidden: Bool
    @State var buttonAndSelection = true
    @State private var safariCacheSize: Double = 0
    @State private var GlobalCacheSize: Double = 0
    @State private var OTACacheSize: Double = 0
    @State private var progressAmount:CGFloat = 0
    @State var safari = false
    @State var appCaches = false
    @State var otaCaches = false
    @State var batteryUsageDat = false
    // Caches
    @State public var logmobileCachesPath = "/var/mobile/Library/Logs/"
    @State public var logCachesPath = "/var/log/"
    @State public var logsCachesPath = "/var/logs/"
    @State public var tmpCachesPath = "/var/tmp/"
    @State public var globalCachesPath = "/var/mobile/Library/Caches/com.apple.CacheDeleteAppContainerCaches.deathrow"
    @State public var phototmpCachePath = "/var/mobile/Media/PhotoData/CPL/storage/filecache/"
    // Safari Caches
    @State public var safariCachePath = "/var/mobile/Containers/Data/Application/Safari/Library/Caches/"
    // OTA Update
    @State public var OTAPath = "/var/MobileSoftwareUpdate/MobileAsset/AssetsV2/com_apple_MobileAsset_SoftwareUpdate/"
    var body: some View {
        NavigationView {
            VStack {
                if buttonAndSelection {
                    if progressAmount >= 0.9 {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                        Text("Done !")
                            .foregroundStyle(.green)
                        Button("Exit", action: {
                            withAnimation {
                                isTabViewHidden.toggle()
                                progressAmount = 0
                                safariCacheSize = 0
                                GlobalCacheSize = 0
                                OTACacheSize = 0
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
                            UIApplication.shared.confirmAlert(title: "Selected options", body: "Safari Caches: \(truelyEnabled(safari))\nGeneral Caches: \(truelyEnabled(appCaches))\nOTA Update Caches: \(truelyEnabled(otaCaches))\nBattery Usage Data: \(truelyEnabled(batteryUsageDat))\n Are you sure you want to permanently delete those files ?", onOK: {
                                print("")
                                withAnimation {
                                    buttonAndSelection.toggle()
                                    isTabViewHidden.toggle()
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
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: safariCachePath)) { size in
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
                            progressAmount = 0
                            safariCacheSize = 0
                            GlobalCacheSize = 0
                            OTACacheSize = 0
                            progressAmount = 0
                            // mess
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: logCachesPath)) { size in
                                GlobalCacheSize += size
                            }
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: logmobileCachesPath)) { size in
                                GlobalCacheSize += size
                            }
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: tmpCachesPath)) { size in
                                GlobalCacheSize += size
                            }
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: phototmpCachePath)) { size in
                                GlobalCacheSize += size
                            }
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: logsCachesPath)) { size in
                                GlobalCacheSize += size
                            }
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: globalCachesPath)) { size in
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
                            calculateDirectorySizeAsync(url: URL(fileURLWithPath: OTAPath)) { size in
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
                            performCleanup()
                            if safari {
                                print("safari")
                                deleteContentsOfDirectory(atPath: safariCachePath)
                            }
                            if appCaches {
                                print("appcaches")
                                deleteContentsOfDirectory(atPath: logmobileCachesPath)
                                deleteContentsOfDirectory(atPath: logCachesPath)
                                deleteContentsOfDirectory(atPath: logsCachesPath)
                                deleteContentsOfDirectory(atPath: tmpCachesPath)
                                deleteContentsOfDirectory(atPath: phototmpCachePath)
                                deleteContentsOfDirectory(atPath: globalCachesPath)
                            }
                            if otaCaches {
                                print("otacaches")
                                deleteContentsOfDirectory(atPath: OTAPath)
                            }
                        }
                }
            }
        }
        .navigationBarTitle("Cleaner")
    }
    func performCleanup() {
        cleanProcess(safari: safari, appCaches: appCaches, otaCaches: otaCaches, batteryUsageDat: batteryUsageDat) { progressHandler in
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
