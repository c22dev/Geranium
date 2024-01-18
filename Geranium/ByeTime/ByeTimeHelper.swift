//
//  ByeTimeHelper.swift
//  Geranium
//
//  Created by cclerc on 29.12.23.
//

import Foundation
import SwiftUI

let STPath = URL(fileURLWithPath: "/var/mobile/Library/Preferences/com.apple.ScreenTimeAgent.plist")
let STString = "/var/mobile/Library/Preferences/com.apple.ScreenTimeAgent.plist"

let STBckPath = "/var/mobile/Library/Preferences/com.apple.ScreenTimeAgent.gerackup"

func DisableScreenTime(screentimeagentd: Bool, usagetrackingd: Bool, homed: Bool, familycircled: Bool){
    var result = ""
    // Backuping ScreenTime preferences if they exists.
    if !FileManager.default.fileExists(atPath: STBckPath) {
        result = RootHelper.copy(from: STPath, to: URL(fileURLWithPath: STBckPath))
        if result != "0" {
            do {
                try FileManager.default.copyItem(at: STPath, to: URL(fileURLWithPath: STBckPath))
            }
            catch {
                print("error")
            }
        }
    }
    
    // Removing Screen Time preferences
    result = RootHelper.removeItem(at: STPath)
    if result != "0" {
        do {
            try FileManager.default.removeItem(at: STPath)
        }
        catch {
            print("error")
        }
    }
    
    // Kill daemons
    if screentimeagentd {
        killall("ScreenTimeAgent")
    }
    if homed {
        killall("homed")
    }
    if usagetrackingd {
        killall("UsageTrackingAgent")
    }
    if familycircled {
        killall("familycircled")
    }
    
    // Remove ScreenTime preferences if STA respawned it (STA= ScreenTimeAgent)
    if !FileManager.default.fileExists(atPath: STBckPath) {
        result = RootHelper.removeItem(at: STPath)
        if result != "0" {
            do {
                try FileManager.default.removeItem(at: STPath)
            }
            catch {
                print("error")
            }
        }
    }
    
    
    // Then we disable the daemon from launchd
    if screentimeagentd {
        daemonManagement(key: "com.apple.ScreenTimeAgent", value: true, plistPath: "/var/db/com.apple.xpc.launchd/disabled.plist")
    }
    if homed {
        daemonManagement(key: "com.apple.homed", value: true, plistPath: "/var/db/com.apple.xpc.launchd/disabled.plist")
    }
    if usagetrackingd {
        daemonManagement(key: "com.apple.UsageTrackingAgent", value: true, plistPath: "/var/db/com.apple.xpc.launchd/disabled.plist")
    }
    if familycircled {
        daemonManagement(key: "com.apple.familycircled", value: true, plistPath: "/var/db/com.apple.xpc.launchd/disabled.plist")
    }
    successVibrate()
    UIApplication.shared.alert(title:"Done !", body:"Please manually reboot your device", withButton: false)
}


func enableBack() {
    var canIProceed = false
    if !FileManager.default.fileExists(atPath: STBckPath) {
        UIApplication.shared.confirmAlert(title: "Backup file not found.", body: "Do you want to look for other backup files (Cowabunga or TrollBox) ?", onOK: {
            try? FileManager.default.removeItem(atPath: STString)
            if FileManager.default.fileExists(atPath: "/var/mobile/Library/Preferences/live.cclerc.ScreenTimeAgent.plist") {
                try? FileManager.default.copyItem(atPath: "/var/mobile/Library/Preferences/live.cclerc.ScreenTimeAgent.plist", toPath: STString)
                doStuff()
            }
            else if FileManager.default.fileExists(atPath: "/var/mobile/Library/Preferences/.BACKUP_com.apple.ScreenTimeAgent.plist") {
                try? FileManager.default.copyItem(atPath: "/var/mobile/Library/Preferences/.BACKUP_com.apple.ScreenTimeAgent.plist", toPath: STString)
                doStuff()
            }
            else {
                UIApplication.shared.confirmAlert(title: "Backup file still not found.", body: "No backup file found. Are you sure you want to proceed ? Old preferences might not be restored.", onOK: {
                    doStuff()
                }, noCancel: false, onCancel: {
                    canIProceed = false
                    return
                })
            }
        }, noCancel: false, onCancel: {
            canIProceed = false
        })
    }
    else {
        try? FileManager.default.removeItem(atPath: STString)
        try? FileManager.default.copyItem(atPath: STBckPath, toPath: STString)
        doStuff()
    }
}

func doStuff() {
    let entriesToRemove = ["com.apple.familycircled", "com.apple.UsageTrackingAgent", "com.apple.ScreenTimeAgent", "com.apple.homed"]
    RootHelper.removeItem(at: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
    RootHelper.copy(from: URL(fileURLWithPath: "/var/db/com.apple.xpc.launchd/disabled.plist"), to: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
    var plist = try? readPlist(atPath: "/var/mobile/Documents/disabled.plist")
    removeEntriesFromPlistArray(plist!, entriesToRemove: entriesToRemove, arrayKey: "YourArrayKey")
    try? writePlist(plist!, toPath: "/var/mobile/Documents/disabled.plist")
    RootHelper.removeItem(at: URL(fileURLWithPath: "/var/db/com.apple.xpc.launchd/disabled.plist"))
    RootHelper.move(from: URL(fileURLWithPath :"/var/mobile/Documents/disabled.plist"), to: URL(fileURLWithPath: "/var/db/com.apple.xpc.launchd/disabled.plist"))
    RootHelper.removeItem(at: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
    RootHelper.setDaemonPermission(url: URL(fileURLWithPath: "/var/db/com.apple.xpc.launchd/disabled.plist"))
    UIApplication.shared.alert(title:"Done !", body:"Please manually reboot your device", withButton: false)
}

func readPlist(atPath path: String) throws -> NSMutableDictionary {
    guard let data = FileManager.default.contents(atPath: path) else {
        throw NSError(domain: "com.example.plistreader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to read plist file at path \(path)"])
    }

    guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? NSMutableDictionary else {
        throw NSError(domain: "com.example.plistreader", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to parse plist data"])
    }

    return plist
}

func removeEntriesFromPlistArray(_ plist: NSMutableDictionary, entriesToRemove: [String], arrayKey: String) {
    guard var array = plist[arrayKey] as? [String] else {
        print("Array not found in plist for key: \(arrayKey)")
        return
    }

    array = array.filter { !entriesToRemove.contains($0) }
    plist[arrayKey] = array
}

func writePlist(_ plist: NSMutableDictionary, toPath path: String) throws {
    let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)

    try data.write(to: URL(fileURLWithPath: path), options: .atomic)
}
