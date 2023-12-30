//
//  ByeTimeHelper.swift
//  Geranium
//
//  Created by cclerc on 29.12.23.
//

import Foundation

let STPath = URL(fileURLWithPath: "/var/mobile/Library/Preferences/com.apple.ScreenTimeAgent.plist")
let STString = "/var/mobile/Library/Preferences/com.apple.ScreenTimeAgent.plist"

let STBckPath = "/var/mobile/Library/Preferences/com.apple.ScreenTimeAgent.gerackup"

func DisableScreenTime(screentimeagentd: Bool, usagetrackingd: Bool, homed: Bool)->String {
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
    // UserSpace Reboot
    successVibrate()
    userspaceReboot()
    return "done"
}
