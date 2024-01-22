//
//  DaemonView.swift
//  Geranium
//
//  Created by Constantin Clerc on 10/12/2023.
//

import SwiftUI
import AlertKit

struct DaemonView: View {
    @State private var searchText = ""
    @State private var daemonFiles: [String] = []
    @State private var labelForDaemon: String?
    @State private var toDisable: [String] = []
    @State private var manageSheet: Bool = false
    @State private var isAlphabeticalOrder: Bool = false
    @State private var isEditing = false
    @State private var selectedItems: Set<String> = Set()
    @State private var initialcount: Int = 0
    @State private var cancelCount: Int = 0
    @AppStorage("isDaemonFirstRun") var isDaemonFirstRun: Bool = true
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    DaemonMainView()
                }
            }
            // This is probably useless.
            else {
                NavigationView {
                    DaemonMainView()
                }
            }
        } else {
            NavigationView {
                DaemonMainView()
            }
        }
    }
    @ViewBuilder
    private func DaemonMainView() -> some View {
        List {
            ForEach(daemonFiles.filter { searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }, id: \.self) { fileName in
                HStack {
                    if isEditing {
                            Image(systemName: selectedItems.contains(getLabel(fileName) ?? fileName) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedItems.contains(getLabel(fileName) ?? fileName) ? .accentColor : .gray)
                    }
                        Text(fileName)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundColor(toDisable.contains(getLabel(fileName) ?? fileName) ? .red : .primary)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if isEditing {
                        toggleSelection(for: getLabel(fileName) ?? fileName)
                        toDisable = Array(selectedItems)
                        miniimpactVibrate()
                    }
                }
                .swipeActions {
                    if let existingIndex = toDisable.firstIndex(of: getLabel(fileName) ?? fileName) {
                        Button(role: .destructive) {
                            toDisable.remove(at: existingIndex)
                            if isAlphabeticalOrder {
                                daemonFiles.sort()
                            }
                        } label: {
                            Label("Enable", systemImage: "hand.thumbsup")
                        }
                        .tint(.green)
                    }
                    else {
                        Button(role: .destructive) {
                            toDisable.append(getLabel(fileName) ?? fileName)
                            if isAlphabeticalOrder {
                                daemonFiles.sort()
                            }
                        } label: {
                            Label("Disable", systemImage: "hand.thumbsdown")
                        }
                    }
                }
                .animation(.easeInOut)
            }
        }
        .searchable(text: $searchText)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Daemons")
                    .font(.title2)
                    .bold()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isEditing {
                        selectedItems.removeAll()
                        withAnimation {
                            isEditing = false
                        }
                    }
                    else {
                        selectedItems = Set(toDisable)
                        withAnimation {
                            isEditing.toggle()
                        }
                        AlertKitAPI.present(
                            title: "Selected",
                            icon: .done,
                            style: .iOS17AppleMusic,
                            haptic: .success
                        )
                    }
                }) {
                    if isEditing {
                        Text("Done")
                            .bold()
                    } else {
                        Image(systemName: "pencil")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !isEditing {
                    Toggle(isOn: $isAlphabeticalOrder) {
                        Label("Alphabetical", systemImage: "textformat")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !isEditing {
                    Button(action: {
                        var error = RootHelper.removeItem(at: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
                        error = RootHelper.copy(from: URL(fileURLWithPath: "/var/db/com.apple.xpc.launchd/disabled.plist"), to: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
                        print(error)
                        error = RootHelper.setPermission(url: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
                        manageSheet.toggle()
                    }) {
                        Image(systemName: "list.bullet")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !isEditing {
                    Button(action: {
                        if toDisable == [] {
                            AlertKitAPI.present(
                                title: "No Daemon Selected !",
                                icon: .error,
                                style: .iOS17AppleMusic,
                                haptic: .error
                            )
                        }
                        else {
                            initialcount = toDisable.count
                            cancelCount = 0
                            processNextDaemon()
                        }
                    }) {
                        Image(systemName: "checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                }
            }
        }
        .onAppear {
            updateDaemonFiles()
        }
        .onChange(of: isAlphabeticalOrder) { newValue in
            if newValue {
                daemonFiles.sort()
            } else {
                updateDaemonFiles()
            }
        }
        .sheet(isPresented: $isDaemonFirstRun) {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    DaemonWelcomeView()
                }
            } else {
                NavigationView {
                    DaemonWelcomeView()
                }
            }
        }
        .sheet(isPresented:$manageSheet) {
            CurrentlyDisabledDaemonView()
                .onDisappear {
                    AlertKitAPI.present(
                        title: "Saved !",
                        icon: .done,
                        style: .iOS17AppleMusic,
                        haptic: .success
                    )
                }
        }
    }
    
    private func updateDaemonFiles() {
        let launchDaemonsURL = URL(fileURLWithPath: "/System/Library/LaunchDaemons/")
        do {
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(atPath: launchDaemonsURL.path)
            daemonFiles = files.map { URL(fileURLWithPath: $0).deletingPathExtension().lastPathComponent }
        } catch {
            UIApplication.shared.alert(body: "error reading LaunchDaemons directory: \(error)")
        }
    }
    
    private func getLabel(_ fileName: String) -> String? {
        let plistURL = URL(fileURLWithPath: "/System/Library/LaunchDaemons/\(fileName).plist")
        do {
            let data = try Data(contentsOf: plistURL)
            let plist = try PropertyListSerialization.propertyList(from: data, format: nil)
            if let dict = plist as? [String: Any], let label = dict["Label"] as? String {
                return label
            }
        } catch {
            UIApplication.shared.alert(body: "Error reading plist: \(error)")
        }
        return nil
    }
    
    private func toggleSelection(for SfileName: String) {
        if selectedItems.contains(SfileName) {
            selectedItems.remove(SfileName)
        } else {
            selectedItems.insert(SfileName)
        }
    }
    
    private func processNextDaemon() {
        guard let nextDaemon = toDisable.first else {
            if cancelCount != initialcount {
                RootHelper.removeItem(at: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
                UIApplication.shared.alert(title: "Done.", body: "Successfully disabled selected daemons. Please manually reboot your device now.", withButton: false)
            }
            else {
                RootHelper.removeItem(at: URL(fileURLWithPath: "/var/mobile/Documents/disabled.plist"))
            }
            initialcount = 0
            cancelCount = 0
            return
        }

        UIApplication.shared.confirmAlert(title: "Are you sure you want to disable \(nextDaemon) ?", body: "You can still undo this action after by going to the manager icon.", onOK: {
            daemonManagement(key: nextDaemon, value: true, plistPath: "/var/db/com.apple.xpc.launchd/disabled.plist")
            toDisable.removeFirst()
            processNextDaemon()
        }, noCancel: false, onCancel: {
            cancelCount += 1
            toDisable.removeFirst()
            processNextDaemon()
        }, yes: true)
    }
}
