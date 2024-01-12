import UIKit
import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    var latitudeDouble: Double = 0.0
    var longitudeDouble: Double = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Helper method to extract query parameters from URL
    private func getParameter(from url: URL, key: String) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return nil
        }
        
        return queryItems.first { $0.name == key }?.value
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if let sharedItems = extensionContext?.inputItems as? [NSExtensionItem],
           let firstItem = sharedItems.first,
           let attachments = firstItem.attachments {
            
            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier as String) {
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier as String, options: nil, completionHandler: { (url, error) in
                        if let url = url as? URL {
                            if let latitude = self.getParameter(from: url, key: "ll")?.components(separatedBy: ",").first,
                               let longitude = self.getParameter(from: url, key: "ll")?.components(separatedBy: ",").last,
                               let latitudeDouble = Double(latitude),
                               let longitudeDouble = Double(longitude) {
                                DispatchQueue.main.async {
                                    let bookmarkName = self.textField.text
                                    print(self.BookMarkSave(lat: latitudeDouble, long: longitudeDouble, name: bookmarkName ?? ""))
                                    self.done()
                                }
                            }
                        }
                    })
                }
            }
        }
        dismiss(animated: true) {
        }
    }

    @IBAction func done() {
        self.extensionContext?.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    let sharedUserDefaultsSuiteName = "group.live.cclerc.geraniumBookmarks"

    func BookMarkSave(lat: Double, long: Double, name: String) -> Bool {
        let bookmark: [String: Any] = ["name": name, "lat": lat, "long": long]
        var bookmarks = BookMarkRetrieve()
        bookmarks.append(bookmark)
        let sharedUserDefaults = UserDefaults(suiteName: sharedUserDefaultsSuiteName)
        sharedUserDefaults?.set(bookmarks, forKey: "bookmarks")
        successVibrate()
        return true
    }

    func BookMarkRetrieve() -> [[String: Any]] {
        let sharedUserDefaults = UserDefaults(suiteName: sharedUserDefaultsSuiteName)
        if let bookmarks = sharedUserDefaults?.array(forKey: "bookmarks") as? [[String: Any]] {
            return bookmarks
        } else {
            return []
        }
    }
}

// shortened vibrate object
func successVibrate() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
}
