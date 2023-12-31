//
//  FileCleaner.swift
//  Geranium
//
//  Created by cclerc on 15.12.23.
//

import Foundation

func cleanProcess(safari: Bool, appCaches: Bool, otaCaches: Bool, leftOverCaches: Bool, progressHandler: @escaping (Double) -> Void) {
    print("in the func")
    var safariCleanedUp = false
    var appCleanedUp = false
    var otaCleanedUp = false
    var leftCleanedUp = false
    var RHResult = ""
    print(safari, appCaches, otaCaches)
    
    DispatchQueue.global().async {
        let totalProgressSteps = 9

        func updateProgress(currentStep: Int) {
            let progress = Double(currentStep) / Double(totalProgressSteps)
            progressHandler(progress)
            miniimpactVibrate()
        }

        for step in 1...totalProgressSteps {
            if safari, !safariCleanedUp {
                print("safari")
                RHResult = deleteContentsOfDirectory(atPath: removeFilePrefix(safariCachePath))
                if RHResult != "0" {
                    progressHandler(-99)
                    return
                }
                updateProgress(currentStep: step)

                RHResult = deleteContentsOfDirectory(atPath: removeFilePrefix(safariImgCachePath))
                if RHResult != "0" {
                    progressHandler(-99)
                    return
                } else {
                    safariCleanedUp = true
                    updateProgress(currentStep: step + 2)
                }
            } else {
                updateProgress(currentStep: step + 2)
            }

            if appCaches, !appCleanedUp {
                print("appcaches")
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

                for path in paths {
                    RHResult = deleteContentsOfDirectory(atPath: path)
                    if RHResult != "0" {
                        progressHandler(-99)
                        return
                    } else {
                        updateProgress(currentStep: step + 3)
                    }
                }
                appCleanedUp = true
                updateProgress(currentStep: step + 4)
            } else {
                updateProgress(currentStep: step + 4)
            }

            if otaCaches, !otaCleanedUp {
                print("otacaches")
                RHResult = deleteContentsOfDirectory(atPath: OTAPath)
                if RHResult != "0" {
                    progressHandler(-99)
                    return
                } else {
                    updateProgress(currentStep: step + 5)
                }
                otaCleanedUp = true
                updateProgress(currentStep: step + 6)
            } else {
                updateProgress(currentStep: step + 6)
            }
            
            if leftOverCaches, !leftCleanedUp {
                let paths = [leftovYT, leftovTikTok, leftovTwitter, leftovSpotify]
                print("leftOv")
                for path in paths {
                    RHResult = deleteContentsOfDirectory(atPath: removeFilePrefix(path))
                    if RHResult != "0" {
                        progressHandler(-99)
                        return
                    } else {
                        updateProgress(currentStep: step + 8)
                    }
                }
                leftCleanedUp = true
                updateProgress(currentStep: step + 9)
            }
            else {
                updateProgress(currentStep: step + 9)
            }
        }
    }
}


// Adapted from https://stackoverflow.com/a/59425817
func directorySize(at url: URL) -> Int64 {
    let fileManager = FileManager.default
    var isDirectory: ObjCBool = false
    guard fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
        return 22
    }

    if !isDirectory.boolValue {
        return 26
    }

    var totalSize: Int64 = 0

    do {
        let contents = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
        for item in contents {
            var isDir: ObjCBool = false
            guard fileManager.fileExists(atPath: item.path, isDirectory: &isDir) else {
                continue
            }

            if isDir.boolValue {
                RootHelper.setPermission(url: item)
                totalSize += directorySize(at: item)
            } else {
                RootHelper.setPermission(url: item)
                
                if let fileSize = (try? fileManager.attributesOfItem(atPath: item.path)[.size]) as? Int64 {
                    totalSize += fileSize
                }
            }
        }
    } catch {
        print("Error calculating folder size: \(error.localizedDescription)")
    }

    return totalSize
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
