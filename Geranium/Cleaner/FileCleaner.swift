//
//  FileCleaner.swift
//  Geranium
//
//  Created by cclerc on 15.12.23.
//

import Foundation

func cleanProcess(safari: Bool, appCaches: Bool, otaCaches: Bool, batteryUsageDat: Bool, progressHandler: @escaping (Double) -> Void) {
    let logmobileCachesPath = "/var/mobile/Library/Logs/"
        let logCachesPath = "/var/log/"
        let logsCachesPath = "/var/logs/"
        let tmpCachesPath = "/var/tmp/"
        let globalCachesPath = "/var/mobile/Library/Caches/com.apple.CacheDeleteAppContainerCaches.deathrow"
        let phototmpCachePath = "/var/mobile/Media/PhotoData/CPL/storage/filecache/"
        // Safari Caches
        let safariCachePath = "/var/mobile/Containers/Data/Application/Safari/Library/Caches/"
        // OTA Update
        let OTAPath = "/var/MobileSoftwareUpdate/MobileAsset/AssetsV2/com_apple_MobileAsset_SoftwareUpdate/"
    print("in the func")
    print(safari, appCaches, otaCaches)
    DispatchQueue.global().async {
           let totalProgressSteps = 9
           for step in 0..<totalProgressSteps {
               let progress = Double(step + 1) / Double(totalProgressSteps)
               DispatchQueue.main.async {
                   progressHandler(progress)
               }
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

func deleteContentsOfDirectory(atPath path: String) {
    do {
        let contents = try FileManager.default.contentsOfDirectory(atPath: path)

        for content in contents {
            let contentPath = (path as NSString).appendingPathComponent(content)
            try FileManager.default.removeItem(atPath: contentPath)
        }

        print("Contents of directory \(path) deleted successfully.")
    } catch {
        print("Error deleting contents of directory \(path): \(error.localizedDescription)")
    }
}
