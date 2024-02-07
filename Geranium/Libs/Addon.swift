//
//  Addon.swift
//  Geranium
//
//  Created by Constantin Clerc on 17/12/2022.
//

import Foundation
import SwiftUI
import Combine
import UIKit

struct MaterialView: UIViewRepresentable {
    let material: UIBlurEffect.Style

    init(_ material: UIBlurEffect.Style) {
        self.material = material
    }

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: material))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: material)
    }
}

fileprivate var cancellables = [String : AnyCancellable] ()

public extension Published {
    init(wrappedValue defaultValue: Value, key: String) {
        let value = UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
        self.init(initialValue: value)
        cancellables[key] = projectedValue.sink { val in
            UserDefaults.standard.set(val, forKey: key)
        }
    }
}

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}

extension View {
    /// Sets the text color for a navigation bar title.
    /// - Parameter color: Color the title should be
    ///
    /// Supports both regular and large titles.
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
    
        // Set appearance for both normal and large sizes.
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
        
        return self
    }
}

func respring() {
    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    
    let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
        let windows: [UIWindow] = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
        
        for window in windows {
            window.alpha = 0
            window.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    animator.addCompletion { _ in
        killall("SpringBoard")
        killall("FrontBoard")
        killall("BackBoard")
        // if others failed...
        UIApplication.shared.respringDeprecated()
        sleep(2)
        exit(0)
    }
    
    animator.startAnimation()
}

func exitGracefully() {
    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
        exit(0)
    }
}


extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}

extension Color {
    init(uiColor14: UIColor) {
        self.init(red: Double(uiColor14.rgba.red),
                  green: Double(uiColor14.rgba.green),
                  blue: Double(uiColor14.rgba.blue),
                  opacity: Double(uiColor14.rgba.alpha))
    }
}

var currentUIAlertController: UIAlertController?

extension UIApplication {
    func dismissAlert(animated: Bool) {
        DispatchQueue.main.async {
            currentUIAlertController?.dismiss(animated: animated)
        }
    }
    func alert(title: String = "Error", body: String, animated: Bool = true, withButton: Bool = true) {
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if withButton { currentUIAlertController?.addAction(.init(title: "OK", style: .cancel)) }
            self.present(alert: currentUIAlertController!)
        }
    }
    func confirmAlert(title: String = "Error", body: String, onOK: @escaping () -> (), noCancel: Bool, onCancel: (() -> ())? = nil, yes: Bool = false) {
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if !noCancel {
                currentUIAlertController?.addAction(.init(title: "Cancel", style: .cancel, handler: { _ in
                    onCancel?()
                }))
            }
            if !yes {
                currentUIAlertController?.addAction(.init(title: "OK", style: noCancel ? .cancel : .default, handler: { _ in
                    onOK()
                }))
            }
            if yes {
                currentUIAlertController?.addAction(.init(title: "Yes", style: noCancel ? .cancel : .default, handler: { _ in
                    onOK()
                }))
            }
            self.present(alert: currentUIAlertController!)
        }
    }
    
    func yesoubiennon(title: String = "Error", body: String, onOK: @escaping () -> (), noCancel: Bool, onCancel: (() -> ())? = nil, yes: Bool) {
        DispatchQueue.main.async {
            currentUIAlertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
            if !noCancel {
                currentUIAlertController?.addAction(.init(title: "No", style: .cancel, handler: { _ in
                    onCancel?()
                }))
            }
            if !yes {
                currentUIAlertController?.addAction(.init(title: "OK", style: noCancel ? .cancel : .default, handler: { _ in
                    onOK()
                }))
            }
            if yes {
                currentUIAlertController?.addAction(.init(title: "Yes", style: noCancel ? .cancel : .default, handler: { _ in
                    onOK()
                }))
            }
            self.present(alert: currentUIAlertController!)
        }
    }
    
    
    func TextFieldAlert(title: String, textFieldPlaceHolder: String, completion: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = textFieldPlaceHolder
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if let text = alertController.textFields?.first?.text {
                completion(text)
            } else {
                completion(nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alert: alertController)
    }
    
    func change(title: String = "Error", body: String) {
        DispatchQueue.main.async {
            currentUIAlertController?.title = title
            currentUIAlertController?.message = body
        }
    }
    
    func present(alert: UIAlertController) {
        if var topController = self.windows[0].rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            topController.present(alert, animated: true)
            // topController should now be your topmost view controller
        }
    }
    
    func respringDeprecated() {
        let app = self
        // Credit to Amy While for this respring bug
        guard let window = app.windows.first else { return }
        while true {
            window.snapshotView(afterScreenUpdates: false)
        }
    }
}

func checkSandbox() -> Bool {
    let fileManager = FileManager.default
    fileManager.createFile(atPath: "/var/mobile/geraniumtemp", contents: nil)
    if fileManager.fileExists(atPath: "/var/mobile/geraniumtemp") {
        do {
            try fileManager.removeItem(atPath: "/var/mobile/geraniumtemp")
        } catch {
            print("Failed to remove sandbox check file")
        }
        return false
    }
    
    return true
}

func impactVibrate() {
    let impact = UIImpactFeedbackGenerator(style: .medium)
    impact.impactOccurred()
}

func miniimpactVibrate() {
    let impact = UIImpactFeedbackGenerator(style: .light)
    impact.impactOccurred()
}
func successVibrate() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}
func errorVibrate() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.error)
}

extension Bundle {
    public var icon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
            let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
            let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
            let lastIcon = iconFiles.last {
            return UIImage(named: lastIcon)
        }
        return nil
    }
}

struct LinkCell: View {
    var imageLink: String
    var url: String
    var title: String
    var description: String
    var systemImage: Bool = false
    var circle: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Group {
                    if let imageURL = URL(string: imageLink) {
                        AsyncImageView(url: imageURL)
                            .frame(width: 30, height: 30)
                            .cornerRadius(25)
                    }
                }
                .aspectRatio(contentMode: .fit)
                
                Button(action: {
                    UIApplication.shared.open(URL(string: url)!)
                }) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color.accentColor)
                }
            }
            Text(description)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct AsyncImageView: View {
    @StateObject private var imageLoader = ImageLoader()

    var url: URL

    var body: some View {
        Group {
            if let uiImage = imageLoader.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            imageLoader.loadImage(from: url)
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = uiImage
                }
            }
        }.resume()
    }
}

func truelyEnabled(_ inputBoolean: Bool) -> String {
    if inputBoolean{
        return "Enabled"
    }
    else {
        return "Disabled"
    }
}

// https://stackoverflow.com/a/76762126
extension View {
@ViewBuilder
func disableListScroll() -> some View {
    if #available(iOS 16.0, *) {
        self
        .scrollDisabled(true)
    } else {
        self
        .simultaneousGesture(DragGesture(minimumDistance: 0), including: .all)
    }
}}

func isMiniDevice() -> Bool {
    let scale = UIScreen.main.scale

    let ppi = scale * ((UIDevice.current.userInterfaceIdiom == .pad) ? 132 : 163);
    let width = UIScreen.main.bounds.size.width * scale
    let height = UIScreen.main.bounds.size.height * scale
    let horizontal = width / ppi, vertical = height / ppi;
    let diagonal = sqrt(pow(horizontal, 2) + pow(vertical, 2))

    let screenSize = String(format: "%0.1f", diagonal)
    let screensize = Float(screenSize) ?? 0.0
    
    if screensize >= 5.5, UIDevice.current.userInterfaceIdiom != .pad {
        return false
    }
    else {
        return true
    }
}

// https://stackoverflow.com/a/56444424
func betterExit() {
    UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
        exit(0)
    }
}
