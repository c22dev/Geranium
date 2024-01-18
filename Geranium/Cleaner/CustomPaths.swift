//
//  CustomPaths.swift
//  Geranium
//
//  Created by cclerc on 15.01.24.
//

import SwiftUI

struct CustomPaths: View {
    @State private var paths: [String] = UserDefaults.standard.stringArray(forKey: "savedPaths") ?? []
    @State private var newPathName = ""
    @State private var isAddingPath = false

    var body: some View {
        NavigationView {
            List {
                ForEach(paths, id: \.self) { path in
                    withAnimation {
                        Text(path)
                    }
                }
                .onDelete(perform: deletePaths)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Custom Paths")
                        .font(.title2)
                        .bold()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        UIApplication.shared.confirmAlert(title: "Are you sure you want to erase all your custom paths ?", body: "This won't clean them but will erase them from your list.", onOK: {
                            paths = []
                            savePaths()
                        }, noCancel: false)
                    }) {
                        if !paths.isEmpty {
                            withAnimation {
                                Text("Clear")
                            }
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        UIApplication.shared.TextFieldAlert(title: "Enter a path you want to add to your list :", textFieldPlaceHolder: "/var/mobile/DCIM/") { chemin in
                            if chemin == ""{
                                UIApplication.shared.alert(title:"Empty text.", body: "Please enter a path.")
                            }
                            else {
                                paths.append(chemin ?? "")
                                savePaths()
                                isAddingPath.toggle()
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
        .overlay(
            Group {
                if paths.isEmpty {
                    VStack {
                        Text("No paths saved.")
                            .foregroundColor(.secondary)
                            .font(.title)
                            .padding()
                            .multilineTextAlignment(.center)
                        Text("To add a path, tap the + button.")
                            .foregroundColor(.secondary)
                            .font(.footnote)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            , alignment: .center
        )
    }

    func deletePaths(at offsets: IndexSet) {
        paths.remove(atOffsets: offsets)
        savePaths()
    }

    func savePaths() {
        UserDefaults.standard.set(paths, forKey: "savedPaths")
    }

    @ViewBuilder
    func addPathView() -> some View {
        VStack {
            Text("Add a New Path")
                .font(.headline)
                .padding()

            TextField("Enter path name", text: $newPathName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            HStack {
                Spacer()
                Button("Cancel") {
                    isAddingPath.toggle()
                }
                .padding()

                Button("Save") {
                    if !newPathName.isEmpty {
                        paths.append(newPathName)
                        savePaths()
                        isAddingPath.toggle()
                    }
                }
                .padding()
                .disabled(newPathName.isEmpty)
            }
        }
        .padding()
    }
}

struct CustomPaths_Previews: PreviewProvider {
    static var previews: some View {
        CustomPaths()
    }
}
