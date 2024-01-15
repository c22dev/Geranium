//
//  CustomPaths.swift
//  Geranium
//
//  Created by cclerc on 15.01.24.
//

import SwiftUI

struct CustomPath: Identifiable {
    var id = UUID()
    var name: String
    var path: String
}


struct CustomPaths: View {
    @State private var customPaths: [CustomPath] = PathsRetrieve().map {
        CustomPath(name: $0["name"] as! String, path: $0["path"] as! String)
    }
    @State private var result: String = ""
    var body: some View {
        NavigationView {
            List {
                ForEach(customPaths) { path in
                    Button(action: {
                        print("my")
                    }) {
                        VStack(alignment: .leading) {
                            Text("\(path.name)")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("Path: \(path.path)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .onDelete(perform: deletePathk)
            }
            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Text("Custom Paths")
//                        .font(.title2)
//                        .bold()
//                }
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        UIApplication.shared.TextFieldAlert(title: "Enter path name", textFieldPlaceHolder: "Example...", completion: { enteredText in
//                        })
//                        }) {
//                            Image(systemName: "plus")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 24, height: 24)
//                        }
//                    }
//                }
            }
            .overlay(
                    Group {
                        if customPaths.isEmpty {
                            VStack {
                                Text("No custom paths saved.")
                                    .foregroundColor(.secondary)
                                    .font(.title)
                                    .padding()
                                    .multilineTextAlignment(.center)
                                Text("To add a path to be cleaned, please tap the + button.")
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                                    .multilineTextAlignment(.center)
                            }
                        }
                    }
                    , alignment: .center
                )
        }
    }
    private func deletePathk(at offsets: IndexSet) {
            customPaths.remove(atOffsets: offsets)
            updatePaths()
        }
    private func updatePaths() {
        let sharedUserDefaults = UserDefaults(suiteName: "customPaths")
        sharedUserDefaults?.set(customPaths.map { ["name": $0.name, "path": $0.path] }, forKey: "customPaths")
        sharedUserDefaults?.synchronize()
    }
}



func PathSave(path: String, name: String) -> Bool {
    let path: [String: Any] = ["name": name, "path": path]
    var paths = PathsRetrieve()
    paths.append(path)
    let sharedUserDefaults = UserDefaults(suiteName: "customPaths")
    sharedUserDefaults?.set(paths, forKey: "customPaths")
    successVibrate()
    return true
}

func PathsRetrieve() -> [[String: Any]] {
    let sharedUserDefaults = UserDefaults(suiteName: "customPaths")
    if let paths = sharedUserDefaults?.array(forKey: "customPaths") as? [[String: Any]] {
        return paths
    } else {
        return []
    }
}
