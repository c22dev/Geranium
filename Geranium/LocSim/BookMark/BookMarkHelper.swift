//
//  BookMarkHelper.swift
//  Geranium
//
//  Created by cclerc on 21.12.23.
//

import Foundation
import SwiftUI

let sharedUserDefaultsSuiteName = "group.live.cclerc.geraniumBookmarks"

func BookMarkSave(lat: Double, long: Double, name: String) -> Bool {
    let bookmark: [String: Any] = ["name": name, "lat": lat, "long": long]
    var bookmarks = BookMarkRetrieve()
    bookmarks.append(bookmark)
    let sharedUserDefaults = UserDefaults(suiteName: sharedUserDefaultsSuiteName)
    sharedUserDefaults?.set(bookmarks, forKey: "bookmarks")
    return true
}

func BookMarkRetrieve() -> [[String: Any]] {
    let sharedUserDefaults = UserDefaults(suiteName: sharedUserDefaultsSuiteName)
    if let bookmarks = sharedUserDefaults?.array(forKey: "bookmarks") as? [[String: Any]] {
        print(bookmarks)
        return bookmarks
    } else {
        return []
    }
}

func isThereAnyMika() -> Bool {
    let plistPath = "/var/mobile/Library/Preferences/com.mika.LocationSimulation.plist"
    guard FileManager.default.fileExists(atPath: plistPath) else {
        return false
    }

    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: plistPath))
        var format: PropertyListSerialization.PropertyListFormat = .xml
        let plist = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &format)
        guard let plistDict = plist as? [String: Any] else {
            print("Plist is not a dictionary.")
            return false
        }
        if let datasArray = plistDict["datas"] as? [Any] {
            return true
        } else {
            return false
        }

    } catch {
        return false
    }
}


func importMika() {
    let plistPath = "/var/mobile/Library/Preferences/com.mika.LocationSimulation.plist"

    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: plistPath))
        var format: PropertyListSerialization.PropertyListFormat = .xml
        let plist = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: &format)
        guard let plistDict = plist as? [String: Any] else {
            print("not a dictionary")
            return
        }
        if let datasArray = plistDict["datas"] as? [[String: Any]] {
            for dataDict in datasArray {
                if let la = dataDict["la"] as? Double,
                   let lo = dataDict["lo"] as? Double,
                   let remark = dataDict["remark"] as? String {
                    BookMarkSave(lat: la, long: lo, name: remark)
                }
            }
        } else {
            print("datas not there")
        }
        UIApplication.shared.alert(title:"Done !",body:"Your saved bookmarks/records from Mika's LocSim were imported.")
    } catch {
        print("cant read file \(error)")
    }
}
