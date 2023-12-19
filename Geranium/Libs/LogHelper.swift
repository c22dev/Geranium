//
//  LogHelper.swift
//  Geranium
//
//  Created by cclerc on 19.12.23.
//

import Foundation
import SwiftUI
import UIKit

func sendLog(_ logMessage: String, isAnalystic: Bool = false) {
    @AppStorage("isLoggingAllowed") var loggingAllowed: Bool = true
    if loggingAllowed {
        let url = URL(string: "https://geraniumlogserv.c22code.repl.co")!
        let responseString = ""
        var message = ""
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if isAnalystic {
            message =  "--Analytic--\nDevice \(getDeviceCode() ?? "\(UIDevice.current.model)unknown")\nVersion \( UIDevice.current.systemVersion)\nApp Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknown")\nTrollStore \(!checkSandbox())\n\nLog\n\(logMessage)"
        }
        else {
            message =  "--Log--\nDevice \(getDeviceCode() ?? "\(UIDevice.current.model)unknown")\nVersion \( UIDevice.current.systemVersion)\nApp Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "unknown")\nTrollStore \(!checkSandbox())\n\nLog\n\(logMessage)"
        }
        let postData = message.data(using: .utf8)
        
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response: \(responseString)")
            }
        }
        task.resume()
    }
}

// https://levelup.gitconnected.com/device-information-in-swift-eef45be38109
func getDeviceCode() -> String? {
    var systemInfo = utsname()
    uname(&systemInfo)
    let modelCode = withUnsafePointer(to: &systemInfo.machine) {
        $0.withMemoryRebound(to: CChar.self, capacity: 1) {
            ptr in String.init(validatingUTF8: ptr)
        }
    }
    return modelCode
}
