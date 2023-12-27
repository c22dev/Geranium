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
    var RHResult = ""
    print(safari, appCaches, otaCaches)
    
    DispatchQueue.global().async {
        let totalProgressSteps = 9
        let stepIncrement = 1.0 / Double(totalProgressSteps)

        func updateProgress(step: Int) {
            let progress = Double(step + 1) * stepIncrement
            progressHandler(progress)
            miniimpactVibrate()
        }

        for step in 0..<totalProgressSteps {
            if safari, !safariCleanedUp {
                print("safari")
                RHResult = deleteContentsOfDirectory(atPath: removeFilePrefix(safariCachePath))
                if RHResult != "0" {
                    progressHandler(-99)
                    return
                }
                updateProgress(step: step)
                
                RHResult = deleteContentsOfDirectory(atPath: removeFilePrefix(safariImgCachePath))
                if RHResult != "0" {
                    progressHandler(-99)
                    return
                } else {
                    safariCleanedUp = true
                    updateProgress(step: step + 2)
                }
            } else {
                updateProgress(step: step + 2)
            }

            if appCaches, !appCleanedUp {
                print("appcaches")
                let paths = [logmobileCachesPath, logCachesPath, logsCachesPath, tmpCachesPath, phototmpCachePath, globalCachesPath]

                for path in paths {
                    RHResult = deleteContentsOfDirectory(atPath: path)
                    if RHResult != "0" {
                        progressHandler(-99)
                        return
                    } else {
                        updateProgress(step: step + 3)
                    }
                }
                appCleanedUp = true
                updateProgress(step: step + 4)
            } else {
                updateProgress(step: step + 4)
            }

            if otaCaches, !otaCleanedUp {
                print("otacaches")
                RHResult = deleteContentsOfDirectory(atPath: OTAPath)
                if RHResult != "0" {
                    progressHandler(-99)
                    return
                } else {
                    updateProgress(step: step + 5)
                }
                otaCleanedUp = true
                updateProgress(step: step + 6)
            } else {
                updateProgress(step: step + 6)
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
