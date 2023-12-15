//
//  DaemonDisabler.swift
//  Geranium
//
//  Created by cclerc on 15.12.23.
//

import Foundation

func daemonManagement(key: String, value: Bool, plistPath: String) {
    // Read the plist file into a mutable dictionary
    guard let plistData = FileManager.default.contents(atPath: plistPath),
          var plistDictionary = try? PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? NSMutableDictionary
    else {
        print("Error")
        return
    }
    plistDictionary[key] = value
    
    if let newData = try? PropertyListSerialization.data(fromPropertyList: plistDictionary, format: .xml, options: 0) {
        do {
            try newData.write(to: URL(fileURLWithPath: plistPath))
        } catch {
            print("Error  \(error)")
        }
    } else {
        print("Error data convert")
    }
}
