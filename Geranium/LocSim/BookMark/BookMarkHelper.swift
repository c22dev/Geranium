//
//  BookMarkHelper.swift
//  Geranium
//
//  Created by cclerc on 21.12.23.
//

import Foundation

func BookMarkSave(lat: Double, long: Double, name: String) -> Bool {
    let bookmark: [String: Any] = ["name": name, "lat": lat, "long": long]
    var bookmarks = BookMarkRetrieve()
    bookmarks.append(bookmark)
    UserDefaults.standard.set(bookmarks, forKey: "bookmarks")
    return true
}

func BookMarkRetrieve() -> [[String: Any]] {
    if let bookmarks = UserDefaults.standard.array(forKey: "bookmarks") as? [[String: Any]] {
        return bookmarks
    } else {
        return []
    }
}
