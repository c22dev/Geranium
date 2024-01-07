//
//  DaemonDisabler.swift
//  Geranium
//
//  Created by cclerc on 15.12.23.
//

import Foundation

func daemonManagement(key: String, value: Bool, plistPath: String) {
    var result = ""
    // copy plist
    var error = RootHelper.copy(from: URL(fileURLWithPath: plistPath), to: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
    print(error)
    error = RootHelper.setPermission(url: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
    guard let plistData = FileManager.default.contents(atPath: "/var/mobile/Documents/disabled.plist"),
          var plistDictionary = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? NSMutableDictionary
    else {
        print("Error")
        return
    }
    plistDictionary[key] = value
    print("new data being transmitted")
    if let newData = try? PropertyListSerialization.data(fromPropertyList: plistDictionary, format: .xml, options: 0) {
        do {
            try newData.write(to: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
        } catch {
            print("Error \(error)")
        }
    } else {
        print("Error data convert")
    }
    // we need to do shit with roothelper
    print("roothelper")
    result = RootHelper.removeItem(at: URL(fileURLWithPath: plistPath))
    print(result)
    print(result)
    print("roothelper2")
    result = RootHelper.move(from: URL(fileURLWithPath :"/var/mobile/Documents/disabled.plist"), to: URL(fileURLWithPath: plistPath))
    print(result)
}

func bundleIdentifier(forProcessName processName: String) -> String? {
    let workspace = NSClassFromString("LSApplicationWorkspace") as AnyObject
    let selector = NSSelectorFromString("defaultWorkspace")
    let applicationWorkspace = workspace.perform(selector).takeUnretainedValue()
    let selectorAllInstalledApplications = NSSelectorFromString("atl_allInstalledApplications")
    let installedApplications = applicationWorkspace.perform(selectorAllInstalledApplications).takeUnretainedValue() as! [AnyObject]
    for appProxy in installedApplications {
        let selectorBundleIdentifier = NSSelectorFromString("atl_bundleIdentifier")
        let bundleIdentifier = appProxy.perform(selectorBundleIdentifier).takeUnretainedValue() as? String

        if let bundleIdentifier = bundleIdentifier {
            let selectorLocalizedName = NSSelectorFromString("atl_fastDisplayName")
            let localizedName = appProxy.perform(selectorLocalizedName).takeUnretainedValue() as? String

            if let localizedName = localizedName, localizedName.lowercased() == processName.lowercased() {
                print("bundle id found for \(processName): \(bundleIdentifier)")
                return bundleIdentifier
            }
        }
    }

    print("not found for \(processName)")
    return nil
}


func isComApple(_ input: String) -> String? {
    if input.hasPrefix("com.apple.") {
        return input
    } else {
        return nil
    }
}
