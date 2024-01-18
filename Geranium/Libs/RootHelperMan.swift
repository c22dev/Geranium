//
//  RootHelperMan.swift
//  Geranium
//
//  Created by cclerc on 18.12.23.
//

// thanks sourceloc
import UIKit

class RootHelper {
    static let rootHelperPath = Bundle.main.url(forAuxiliaryExecutable: "GeraniumRootHelper")?.path ?? "/"
    
    static func whatsthePath() -> String {
        return rootHelperPath
    }
    
    static func writeStr(_ str: String, to url: URL) -> String  {
        let code = spawnRoot(rootHelperPath, ["writedata", str, url.path], nil, nil)
        return String(code)
    }
    static func move(from sourceURL: URL, to destURL: URL) -> String {
        let code = spawnRoot(rootHelperPath, ["filemove", sourceURL.path, destURL.path], nil, nil)
        return String(code)
    }
    static func copy(from sourceURL: URL, to destURL: URL) -> String {
        let code = spawnRoot(rootHelperPath, ["filecopy", sourceURL.path, destURL.path], nil, nil)
        return String(code)
    }
    static func createDirectory(at url: URL) -> String {
        let code = spawnRoot(rootHelperPath,  ["makedirectory", url.path, ""], nil, nil)
        return String(code)
    }
    static func removeItem(at url: URL) -> String  {
        let code = spawnRoot(rootHelperPath, ["removeitem", url.path, ""], nil, nil)
        return String(code)
    }
    static func setPermission(url: URL) -> String {
        let code = spawnRoot(rootHelperPath, ["permissionset", url.path, ""], nil, nil)
        return String(code)
    }
    static func setDaemonPermission(url: URL) -> String {
        let code = spawnRoot(rootHelperPath, ["daemonperm", url.path, ""], nil, nil)
        return String(code)
    }
    static func rebuildIconCache() -> String {
        let code = spawnRoot(rootHelperPath, ["rebuildiconcache", "", ""], nil, nil)
        return String(code)
    }
    static func loadMCM() -> String {
        let code = spawnRoot(rootHelperPath, ["", "", ""], nil, nil)
        return String(code)
    }
}
