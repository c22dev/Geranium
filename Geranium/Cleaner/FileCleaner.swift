//
//  FileCleaner.swift
//  Geranium
//
//  Created by cclerc on 15.12.23.
//

import Foundation

func cleanProcess(cleanPaths: CleanPaths,safari: Bool, appCaches: Bool, otaCaches: Bool, batteryUsageDat: Bool, progressHandler: @escaping (Double) -> Void) {
    DispatchQueue.global().async {
        let totalProgressSteps = 9
        
        for step in 0..<totalProgressSteps {
            let progress = Double(step + 1) / Double(totalProgressSteps)
            DispatchQueue.main.async {
                progressHandler(progress)
            }
            print(cleanPaths.safariCachePath)
            usleep(50000)
        }
    }
}

// https://stackoverflow.com/a/59425817
func directorySize(url: URL) -> Int64 {
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


class CleanPaths: ObservableObject {
    // Caches
    @Published var logmobileCachesPath = "/var/mobile/Library/Logs/"
    @Published var logCachesPath = "/var/log/"
    @Published var logsCachesPath = "/var/logs/"
    @Published var tmpCachesPath = "/var/tmp/"
    @Published var globalCachesPath = "/var/mobile/Library/Caches/com.apple.CacheDeleteAppContainerCaches.deathrow"
    @Published var phototmpCachePath = "/var/mobile/Media/PhotoData/CPL/storage/filecache/"
    // Safari Caches
    @Published var safariCachePath = "/var/mobile/Containers/Data/Application/Safari/Library/Caches/"
    // OTA Update
    @Published var OTAPath = "/var/MobileSoftwareUpdate/MobileAsset/AssetsV2/com_apple_MobileAsset_SoftwareUpdate/"
}
