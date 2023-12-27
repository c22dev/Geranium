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
func calculateDirectorySizeAsync(url: URL, completion: @escaping (Double) -> Void) {
    DispatchQueue.global().async {
        let size = Double(directorySize(url: url))
        DispatchQueue.main.async {
            completion(size)
        }
    }
}

func getSizeForGeneralCaches() -> Double {
    var GlobalCacheSize: Double = 0
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
    return GlobalCacheSize
}

func getSizeForSafariCaches() -> Double  {
    var safariCacheSize: Double = 0
    calculateDirectorySizeAsync(url: URL(fileURLWithPath: removeFilePrefix(safariCachePath))) { size in
        safariCacheSize += size
    }
    calculateDirectorySizeAsync(url: URL(fileURLWithPath: removeFilePrefix(safariImgCachePath))) { size in
        safariCacheSize += size
    }
    return safariCacheSize
}

func getSizeForOTA() -> Double {
    var OTACacheSize: Double = 0
    calculateDirectorySizeAsync(url: URL(fileURLWithPath: OTAPath)) { size in
        OTACacheSize = size
    }
    return OTACacheSize
}
