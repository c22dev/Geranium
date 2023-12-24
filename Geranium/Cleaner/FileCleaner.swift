//
//  FileCleaner.swift
//  Geranium
//
//  Created by cclerc on 15.12.23.
//

import Foundation

func cleanProcess(safari: Bool, appCaches: Bool, otaCaches: Bool, batteryUsageDat: Bool, progressHandler: @escaping (Double) -> Void) {
    print("in the func")
    var safariCleanedUp = false
    var appCleanedUp = false
    var otaCleanedUp = false
    print(safari, appCaches, otaCaches)
    var RHResult = ""
    DispatchQueue.global().async {
        let totalProgressSteps = 9
        for step in 0..<totalProgressSteps {
            let progress = Double(step + 1) / Double(totalProgressSteps)
            if safari, !safariCleanedUp {
                print("safari")
                RHResult = deleteContentsOfDirectory(atPath: removeFilePrefix((safariCachePath)))
                if RHResult != "0" {
                    progressHandler(-99)
                }
                progressHandler(0.1)
                RHResult = deleteContentsOfDirectory(atPath: removeFilePrefix((safariImgCachePath)))
                if RHResult != "0" {
                    progressHandler(-99)
                }
                else {
                    safariCleanedUp = true
                    progressHandler(0.3)
                    miniimpactVibrate()
                }
            }
            else {
                progressHandler(0.3)
                miniimpactVibrate()
            }
            if appCaches, !appCleanedUp {
                print("appcaches")
                RHResult = deleteContentsOfDirectory(atPath: logmobileCachesPath)
                if RHResult != "0" {
                    progressHandler(-99)
                }
                else {
                    progressHandler(0.35)
                    miniimpactVibrate()
                }
                RHResult = deleteContentsOfDirectory(atPath: logCachesPath)
                if RHResult != "0" {
                    progressHandler(-99)
                }
                else {
                    progressHandler(0.4)
                    miniimpactVibrate()
                }
                RHResult = deleteContentsOfDirectory(atPath: logsCachesPath)
                if RHResult != "0" {
                    progressHandler(-99)
                }
                else {
                    progressHandler(0.45)
                    miniimpactVibrate()
                }
                RHResult = deleteContentsOfDirectory(atPath: tmpCachesPath)
                if RHResult != "0" {
                    progressHandler(-99)
                }
                else {
                    progressHandler(0.5)
                    miniimpactVibrate()
                }
                RHResult = deleteContentsOfDirectory(atPath: phototmpCachePath)
                if RHResult != "0" {
                    progressHandler(-99)
                }
                else {
                    progressHandler(0.55)
                    miniimpactVibrate()
                }
                RHResult = deleteContentsOfDirectory(atPath: globalCachesPath)
                if RHResult != "0" {
                    progressHandler(-99)
                }
                else {
                    appCleanedUp = true
                    progressHandler(0.6)
                    miniimpactVibrate()
                }
            }
            else {
                progressHandler(0.6)
                miniimpactVibrate()
            }
            if otaCaches, !otaCleanedUp {
                print("otacaches")
                RHResult = deleteContentsOfDirectory(atPath: OTAPath)
                progressHandler(0.75)
                miniimpactVibrate()
                if RHResult != "0" {
                    progressHandler(-99)
                }
                progressHandler(0.9)
                miniimpactVibrate()
                otaCleanedUp = true
            }
            else {
                progressHandler(0.9)
                miniimpactVibrate()
            }
        }
    }
}

// https://stackoverflow.com/a/59425817
func directorySize(url: URL) -> Int64 {
    DispatchQueue.global().async {
        RootHelper.setPermission(url: url)
    }
    let contents: [URL]
    do {
        contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey])
    } catch {
        return 0
    }

    var size: Int64 = 0

    for url in contents {
        let isDirectoryResourceValue: URLResourceValues
        do {
            isDirectoryResourceValue = try url.resourceValues(forKeys: [.isDirectoryKey])
        } catch {
            continue
        }
    
        if isDirectoryResourceValue.isDirectory == true {
            size += directorySize(url: url)
        } else {
            let fileSizeResourceValue: URLResourceValues
            do {
                fileSizeResourceValue = try url.resourceValues(forKeys: [.fileSizeKey])
            } catch {
                continue
            }
        
            size += Int64(fileSizeResourceValue.fileSize ?? 0)
        }
    }
    return size
}

func deleteContentsOfDirectory(atPath path: String) -> String {
        var log = RootHelper.setPermission(url: URL(fileURLWithPath: path))
        print(log)
        let log2 = RootHelper.removeItem(at: URL(fileURLWithPath: path))
        log = RootHelper.createDirectory(at: URL(fileURLWithPath: path))
        print(log2)
    // set perms again else things won't work properly for mobile registered paths
        log = RootHelper.setPermission(url: URL(fileURLWithPath: path))
        print(log)
        print("Contents of directory \(path) deleted")
        return(log2)
}
