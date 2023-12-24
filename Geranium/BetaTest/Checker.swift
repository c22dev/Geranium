//
//  File.swift
//  Geranium
//
//  Created by cclerc on 24.12.23.
//

import Foundation
import SwiftUI

struct BetaView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        @State var textPlaceHorder = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        @State var validation = ""
        @State var isEnrolled = false
        var timer: Timer?
        VStack {
            Image(uiImage: Bundle.main.icon!)
                .cornerRadius(10)
            Text("Welcome to Geranium Beta Testing Program")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            Text("Please copy your UUID and send it to a developer in charge.")
                .padding()
                .multilineTextAlignment(.center)
            Text(textPlaceHorder)
                .padding()
                .multilineTextAlignment(.center)
                .textSelection(.enabled)
            Text(validation)
                .padding()
                .multilineTextAlignment(.center)
            if !isEnrolled {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                    .scaleEffect(1.0, anchor: .center)
                Text("You might want to quit and go back in the app.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                    .padding(.top)
                    .multilineTextAlignment(.center)
            }
        }
        .interactiveDismissDisabled()
        .onAppear {
            if isDeviceEnrolled() {
                print("should quit ?")
                isEnrolled.toggle()
                close()
            }
            timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
                if isDeviceEnrolled() {
                    print("should quit ?")
                    isEnrolled.toggle()
                    close()
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    func close() {
        dismiss()
    }
}

func isDeviceEnrolled() -> Bool {
    var result = false
    let semaphore = DispatchSemaphore(value: 0)

    let url = URL(string: "https://cclerc.ch/db/geranium/enrolement.txt")!
    var request = URLRequest(url: url)
    request.cachePolicy = .reloadIgnoringLocalCacheData

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        defer {
            semaphore.signal()
        }

        if let error = error {
            print("Error: \(error)")
            return
        }

        guard let data = data else {
            print("No data received")
            return
        }

        if let fileContent = String(data: data, encoding: .utf8) {
            let vendorID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
            result = fileContent.contains(vendorID)
            if result {
                print("User is in the beta program")
            }
        } else {
            print("Failed to convert data to string")
        }
    }

    task.resume()
    semaphore.wait()
    return result
}
