//
//  Paths.swift
//  Geranium
//
//  Created by cclerc on 22.12.23.
//

import Foundation
import SwiftUI

// Caches
public var logmobileCachesPath = "/var/mobile/Library/Logs/"
public var logCachesPath = "/var/log/"
public var logsCachesPath = "/var/logs/"
public var tmpCachesPath = "/var/tmp/"
public var globalCachesPath = "/var/mobile/Library/Caches/com.apple.CacheDeleteAppContainerCaches.deathrow"
public var phototmpCachePath = "/var/mobile/Media/PhotoData/CPL/storage/filecache/"
// Safari Caches
public var safariCachePath = "\(getBundleDir(bundleID: "com.apple.mobilesafari"))Library/Caches/"
public var safariImgCachePath = "\(getBundleDir(bundleID: "com.apple.mobilesafari"))Library/Image Cache/"
// OTA Update
public var OTAPath = "/var/MobileSoftwareUpdate/MobileAsset/AssetsV2/com_apple_MobileAsset_SoftwareUpdate/"

// credit to bomberfish
public func getBundleDir(bundleID: String) -> URL {
    let fm = FileManager.default
    var returnedurl = URL(string: "none")
    var dirlist = [""]

    do {
        dirlist = try fm.contentsOfDirectory(atPath: "/var/mobile/Containers/Data/Application/")
        // print(dirlist)
    } catch {
        return URL(fileURLWithPath: "Could not access/var/mobile/Containers/Data/Application/.\n\(error.localizedDescription)")
    }

    for dir in dirlist {
        // print(dir)
        let mmpath = "/var/mobile/Containers/Data/Application/" + dir + "/.com.apple.mobile_container_manager.metadata.plist"
        // print(mmpath)
        do {
            var mmDict: [String: Any]
            if fm.fileExists(atPath: mmpath) {
                mmDict = try PropertyListSerialization.propertyList(from: Data(contentsOf: URL(fileURLWithPath: mmpath)), options: [], format: nil) as? [String: Any] ?? [:]

                // print(mmDict as Any)
                if mmDict["MCMMetadataIdentifier"] as! String == bundleID {
                    returnedurl = URL(fileURLWithPath: "/var/mobile/Containers/Data/Application/").appendingPathComponent(dir)
                }
            } else {
                print("WARNING: Directory \(dir) does not have a metadata plist")
            }
        } catch {
            print("Could not get data of \(mmpath): \(error.localizedDescription)")
            return URL(fileURLWithPath: "Could not get data of \(mmpath): \(error.localizedDescription)")
        }
    }
    if returnedurl != URL(string: "none") {
        return returnedurl!
    } else {
        return URL(fileURLWithPath: "App \(bundleID) cannot be found, is a system app, or is not installed.")
    }
}

// catgpt
func removeFilePrefix(_ urlString: String) -> String {
    if urlString.hasPrefix("file://") {
        let index = urlString.index(urlString.startIndex, offsetBy: 7)
        return String(urlString[index...])
    }
    return urlString
}