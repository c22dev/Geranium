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
                    Text(path)
                }
                .onDelete(perform: deletePaths)
            }
            .navigationTitle("Custom Paths")
            .navigationBarItems(trailing: Button(action: {
                isAddingPath.toggle()
            }) {
                Image(systemName: "plus")
            })
        }
        .sheet(isPresented: $isAddingPath) {
            addPathView()
        }
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
