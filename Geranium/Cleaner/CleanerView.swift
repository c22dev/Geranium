//
//  CleanerView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI


struct CleanerView: View {
    // view stuff
//    @Binding var isTabViewHidden: Bool
    @State var cleanerTitle = true
    @State var exitStatus = false
    @State var loadingBarStatus = false
    @State var buttonAndSelection = true
    @State var errorDetecteed = false
    @State var isInfoSheetOn = false
    // sizes
    @State private var safariCacheSize: Double = 0
    @State private var GlobalCacheSize: Double = 0
    @State private var OTACacheSize: Double = 0
    @State private var progressAmount:CGFloat = 0
    // user selection
    @State var safari = false
    @State var appCaches = false
    @State var otaCaches = false
    @State var batteryUsageDat = false
    // roothelper output
    @State var RHResult = ""
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
            if buttonAndSelection {
                if progressAmount >= 0.9, !errorDetecteed {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .onAppear {
                            successVibrate()
                        }
                    Text("Done !")
                        .foregroundStyle(.green)
                    Button("Exit", action: {
                        withAnimation {
//                            isTabViewHidden = false
                            cleanerTitle = true
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
                else if errorDetecteed {
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
                            buttonAndSelection = true
//                            isTabViewHidden = false
                            cleanerTitle = true
                            errorDetecteed.toggle()
                            progressAmount = 0
                            safariCacheSize = 0
                            GlobalCacheSize = 0
                            OTACacheSize = 0
                            progressAmount = 0
                        }
                    })
                    .padding(10)
                    .background(.red)
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .transition(.scale)
                }
                else {
                    if safari || appCaches || otaCaches || batteryUsageDat {
                        Button("Clean !", action: {
                            UIApplication.shared.confirmAlert(title: "Selected options", body: "Safari Caches: \(truelyEnabled(safari))\nGeneral Caches: \(truelyEnabled(appCaches))\nOTA Update Caches: \(truelyEnabled(otaCaches))\nBattery Usage Data: \(truelyEnabled(batteryUsageDat))\n Are you sure you want to permanently delete those files ?", onOK: {
                                print("")
                                withAnimation {
                                    buttonAndSelection.toggle()
//                                    isTabViewHidden = true
                                    cleanerTitle = false
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
                                print("")
                                withAnimation {
                                    buttonAndSelection.toggle()
//                                    isTabViewHidden = true
                                    cleanerTitle = false
                                }
                            }, noCancel: false, yes: true)
                        })
                    .padding(10)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .foregroundColor(.black)
                    .transition(.scale)
                    .disabled(true)
                    }
                    Toggle(isOn: $safari) {
                        Image(systemName: "safari")
                        Text("Safari Caches")
                        Text(">"+String(format: "%.2f MB", safariCacheSize / (1024 * 1024)))
                    }
                    .toggleStyle(checkboxiOS())
                    .padding(2)
                    .onAppear {
                        calculateDirectorySizeAsync(url: URL(fileURLWithPath: removeFilePrefix(safariCachePath))) { size in
                            safariCacheSize += size
                        }
                        calculateDirectorySizeAsync(url: URL(fileURLWithPath: removeFilePrefix(safariImgCachePath))) { size in
                            safariCacheSize += size
                        }
                    }
                    Toggle(isOn: $appCaches) {
                        Image(systemName: "app.dashed")
                        Text("General Caches")
                        Text(">" + String(format: "%.2f MB", GlobalCacheSize / (1024 * 1024)))
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
                    }
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                if cleanerTitle {
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
                    buttonAndSelection.toggle()
                }
            }
            if (progressAmount < -5) {
                errorDetecteed = true
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
