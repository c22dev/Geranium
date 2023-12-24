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
        VStack {
            Image(uiImage: Bundle.main.icon!)
                .cornerRadius(10)
            Text("Welcome to Geranium Beta Testing Program")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            Text("Please copy your UUID bellow and send it to a developer in charge.")
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
            isDeviceEnrolled { isPresent in
                if isPresent {
                    print("user is in beta program")
                    isEnrolled = true
                    close()
                } else {
                    validation = "Your device isn't in the beta program."
                }
            }
        }
    }
    func close() {
        dismiss()
    }
}

func isDeviceEnrolled(completion: @escaping (Bool) -> Void) {
    let url = URL(string: "https://cclerc.ch/db/geranium/enrolement.txt")!
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error: \(error)")
            completion(false)
            return
        }
        guard let data = data else {
            print("No data received")
            completion(false)
            return
        }
        if let fileContent = String(data: data, encoding: .utf8) {
            let vendorID = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
            let isPresent = fileContent.contains(vendorID)
            print("user is in beta program")
            completion(isPresent)
        } else {
            print("Failed to convert data to string")
            completion(false)
        }
    }
    task.resume()
}
