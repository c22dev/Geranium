//
//  DaemonDisabler.swift
//  Geranium
//
//  Created by cclerc on 15.12.23.
//

import Foundation

func daemonManagement(key: String, value: Bool, plistPath: String) {
    var result = ""
    // copy plist
    // is that catgpt ?
    let appTmpDirURL = FileManager.default.temporaryDirectory.appendingPathComponent(Bundle.main.bundleIdentifier ?? "")
    let error = RootHelper.copy(from: URL(fileURLWithPath: plistPath), to: URL(fileURLWithPath: "\(appTmpDirURL)/disabled.plist"))
    guard let plistData = FileManager.default.contents(atPath: "\(appTmpDirURL)/disabled.plist"),
          var plistDictionary = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? NSMutableDictionary
    else {
        print("Error")
        return
    }
    plistDictionary[key] = value
    
    if let newData = try? PropertyListSerialization.data(fromPropertyList: plistDictionary, format: .xml, options: 0) {
        do {
            try newData.write(to: URL(fileURLWithPath: "\(appTmpDirURL)/disabled.plist"))
        } catch {
            print("Error \(error)")
        }
    } else {
        print("Error data convert")
    }
    // we need to do shit with roothelper
    result = RootHelper.removeItem(at: URL(fileURLWithPath: plistPath))
    print(result)
    result = RootHelper.move(from: URL(fileURLWithPath :"\(appTmpDirURL)/disabled.plist"), to: URL(fileURLWithPath: plistPath))
}
