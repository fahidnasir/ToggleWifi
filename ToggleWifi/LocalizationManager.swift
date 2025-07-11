//
//  LocalizationManager.swift
//  ToggleWifi
//
//  Created by Fahid Nasir on 7/12/25.
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: String = "en"
    
    static let shared = LocalizationManager()
    
    private init() {
        // Load saved language or use system default
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") {
            currentLanguage = savedLanguage
        } else {
            currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        }
        setLanguage(currentLanguage)
    }
    
    func setLanguage(_ languageCode: String) {
        currentLanguage = languageCode
        UserDefaults.standard.set(languageCode, forKey: "selectedLanguage")
        UserDefaults.standard.synchronize()
        
        // Update the bundle for localization
        Bundle.setLanguage(languageCode)
    }
    
    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}

// Extension to help with bundle language switching
extension Bundle {
    private static var bundle: Bundle!
    
    public static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, AnyLanguageBundle.self)
        }
        
        if let path = Bundle.main.path(forResource: language, ofType: "lproj") {
            bundle = Bundle(path: path)
        } else {
            bundle = Bundle.main
        }
    }
    
    class AnyLanguageBundle: Bundle, @unchecked Sendable {
        override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
            return Bundle.bundle.localizedString(forKey: key, value: value, table: tableName)
        }
    }
}
