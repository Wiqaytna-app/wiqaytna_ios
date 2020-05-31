//
//  UpdateLanguage.swift
//  Wiqaytna
//
//  Created by Abdel Ali on 4/25/20.
//  Copyright © 2020 Wiqaytna. All rights reserved.
//
//

import Foundation
import UIKit
import IQKeyboardManagerSwift

let kCurrentLanguageKey = "CurrentLanguageKey"
let kDefaultLanguage = "ar"
let kBaseBundle = "Base"
let kLanguageChangeNotification = "LanguageChangeNotification"

class LanguageManager: NSObject {
    
    /// List available languages
    class func availableLanguages(_ excludeBase: Bool = true) -> [String] {
        var availableLanguages = Bundle.main.localizations
        // If excludeBase = true, don't include "Base" in available languages
        if let indexOfBase = availableLanguages.firstIndex(of: "Base"), excludeBase == true {
            availableLanguages.remove(at: indexOfBase)
        }
        return availableLanguages
    }
    
    /// Current language
    class func currentLanguage() -> String {
        if let currentLanguage = UserDefaults.standard.object(forKey: kCurrentLanguageKey) as? String {
            return currentLanguage
        }
        return defaultLanguage()
    }
    
    /// Change the current language
    class func setCurrentLanguage(_ language: String) {
        let selectedLanguage = availableLanguages().contains(language) ? language : defaultLanguage()
        if (selectedLanguage != currentLanguage()) {
            UserDefaults.standard.set(selectedLanguage, forKey: kCurrentLanguageKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
        }
    }
    
    /// Default language
    class func defaultLanguage() -> String {
        var defaultLanguage: String = String()
        guard let preferredLanguage = Bundle.main.preferredLocalizations.first else {
            return kDefaultLanguage
        }
        let availableLanguages: [String] = self.availableLanguages()
        if (availableLanguages.contains(preferredLanguage)) {
            defaultLanguage = preferredLanguage
        } else {
            defaultLanguage = kDefaultLanguage
        }
        return defaultLanguage
    }
    
    class func loopThroughSubViewAndReAddThem() {
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done".localized()
        for window in UIApplication.shared.windows {
            if !window.isKind(of: NSClassFromString("UITextEffectsWindow") ?? NSString.classForCoder()) {
                window.subviews.forEach {
                    $0.removeFromSuperview()
                    window.addSubview($0)
                }
            }
        }
    }
}

extension String {
    
    /**
     Localize a String
     - parameter tableName: The receiver’s string table to search. If tableName is `nil`
     or is an empty string, the method attempts to use `Localizable.strings`.
     - parameter bundle: The receiver’s bundle to search. If bundle is `nil`,
     the method attempts to use main bundle.
     - returns: The localized string.
     */
    func localized(using tableName: String? = nil, in bundle: Bundle = .main) -> String {
        if let path = bundle.path(forResource: LanguageManager.currentLanguage(), ofType: "lproj"), let currentLanguageBundle = Bundle(path: path) {
            
            let localizedString = currentLanguageBundle.localizedString(forKey: self, value: nil, table: tableName)
            if localizedString == self, let basePath = bundle.path(forResource: kBaseBundle, ofType: "lproj"), let bundle = Bundle(path: basePath) {
                return bundle.localizedString(forKey: self, value: nil, table: tableName)
            }
            return localizedString
        } else if let path = bundle.path(forResource: kBaseBundle, ofType: "lproj"),
            let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: tableName)
        }
        return self
    }
    
}

@IBDesignable public extension UIButton {
    
    @IBInspectable var localizeKey: String? {
        set {
            DispatchQueue.main.async {
                self.setTitle(newValue?.localized(), for: .normal)
            }
        }
        get {
            return self.titleLabel?.text
        }
    }
}

@IBDesignable public extension UITextView {
    
    @IBInspectable var localizeKey: String? {
        set {
            DispatchQueue.main.async {
                self.text = newValue?.localized()
            }
        }
        get {
            return self.text
        }
    }
}

@IBDesignable public extension UITextField {
    @IBInspectable var localizeKey: String? {
        set {
            DispatchQueue.main.async {
                self.placeholder = newValue?.localized()
            }
        }
        get {
            return self.placeholder
        }
    }
}

@IBDesignable public extension UILabel {
    @IBInspectable var localizeKey: String? {
        set {
            // set new value from dictionary
            DispatchQueue.main.async {
                self.text = newValue?.localized()
            }
        }
        get {
            return self.text
        }
    }
}
