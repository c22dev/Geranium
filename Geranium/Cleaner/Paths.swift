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
public var mailmessdat = "/var/mobile/Library/Mail/MessageData"
public var mailattach = "/var/mobile/Library/Mail/AttachmentData"
public var deletedVideos = "/var/mobile/Media/PhotoData/Thumbnails/VideoKeyFrames/DCIM"
public var deletedPhotos = "/var/mobile/Media/PhotoData/Thumbnails/V2/PhotoData/CPLAssets"
public var phototmpCachePath = "/var/mobile/Media/PhotoData/CPL/storage/filecache/"
public var photoOther = "/var/mobile/Media/PhotoData/Thumbnails/V2/DCIM"
// Safari Caches
public var safariCachePath = "\(getBundleDir(bundleID: "com.apple.mobilesafari"))Library/Caches/"
public var safariImgCachePath = "\(getBundleDir(bundleID: "com.apple.mobilesafari"))Library/Image Cache/"
// OTA Update
public var OTAPath = "/var/MobileSoftwareUpdate/MobileAsset/AssetsV2/com_apple_MobileAsset_SoftwareUpdate/"
// Leftovers
public var leftovYT = "\(getBundleDir(bundleID: "com.google.ios.youtube"))Documents/Carida_Files/"
public var leftovTikTok = "\(getBundleDir(bundleID: "com.zhiliaoapp.musically"))/Documents/drafts/"
public var leftovTwitter = "\(getBundleDir(bundleID: "com.atebits.Tweetie2"))/Caches/"
public var leftovSpotify = "\(getBundleDir(bundleID: "com.spotify.client"))/Caches/"

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
        let size = Double(directorySize(at: url))
        DispatchQueue.main.async {
            completion(size)
        }
    }
}

func getSizeForGeneralCaches(completion: @escaping (Double) -> Void) {
    var globalCacheSize: Double = 0
    
    let paths = [
        logCachesPath,
        logmobileCachesPath,
        tmpCachesPath,
        phototmpCachePath,
        logsCachesPath,
        globalCachesPath,
        mailmessdat,
        mailattach,
        deletedVideos,
        deletedPhotos,
        photoOther
    ]
    
    var remainingPaths = paths.count
    
    for path in paths {
        calculateDirectorySizeAsync(url: URL(fileURLWithPath: path)) { size in
            globalCacheSize += size
            remainingPaths -= 1
            
            if remainingPaths == 0 {
                completion(globalCacheSize)
            }
        }
    }
}

func getSizeForSafariCaches(completion: @escaping (Double) -> Void) {
    var safariCacheSize: Double = 0
    calculateDirectorySizeAsync(url: URL(fileURLWithPath: removeFilePrefix(safariCachePath))) { size in
        safariCacheSize += size
        calculateDirectorySizeAsync(url: URL(fileURLWithPath: removeFilePrefix(safariImgCachePath))) { size in
            safariCacheSize += size
            completion(safariCacheSize)
        }
    }
}

func getSizeForOTA(completion: @escaping (Double) -> Void) {
    calculateDirectorySizeAsync(url: URL(fileURLWithPath: OTAPath)) { size in
        completion(size)
    }
}

func getSizeForAppLeftover(completion: @escaping (Double) -> Void) {
    var leftOverCacheSize: Double = 0
    
    let paths = [
        leftovYT,
        leftovTikTok,
        leftovTwitter,
        leftovSpotify
    ]
    
    var remainingPaths = paths.count
    
    for path in paths {
        calculateDirectorySizeAsync(url: URL(fileURLWithPath: path)) { size in
            leftOverCacheSize += size
            remainingPaths -= 1
            
            if remainingPaths == 0 {
                completion(leftOverCacheSize)
            }
        }
    }
}

func draftWarning(isEnabled: Bool = false)-> String {
    if isEnabled {
        return "\nThe options you selected will clean your Drafts in some apps (e.g. TikTok)"
    }
    else {
        return ""
    }
}
