//
//  CGUVC.swift
//  Wiqaytna
//
//  Created by ABDELAZiZ on 5/11/20.
//  Copyright © 2020 Wiqaytna. All rights reserved.
//

import UIKit
import WebKit
import Firebase

class CGUVC: UIViewController {
    
    @IBOutlet weak var switchLanguageLabel: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _parameters = ["id":16, "screen":"ecran des CGU"] as [String : Any]
        Analytics.logEvent("CGU_screen", parameters: _parameters)
        self.updateWebView()
        updateText()
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
    }
    
    
    func updateWebView() {
        do {
            var nameFilePath = "CDU_AR"
            if LanguageManager.currentLanguage() == "ar" {
                nameFilePath = "CDU_AR"
            }
            if LanguageManager.currentLanguage() == "fr" {
                nameFilePath = "CDU_FR"
            }
            
            guard let filePath = Bundle.main.path(forResource: nameFilePath, ofType: "html")
                else {
                    print ("File reading error")
                    return
            }
            let contents =  try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: filePath)
            webView.loadHTMLString(contents as String, baseURL: baseUrl)
        }
        catch {
            print ("File HTML error")
        }
    }
    
    
    @objc func updateText() {
        switchLanguageLabel.setTitle(LanguageManager.currentLanguage() == "fr" ? "langAR".localized() : "langFR".localized(), for: .normal)
        LanguageManager.loopThroughSubViewAndReAddThem()
    }
    
    @IBAction func switchLanguageAction(_ sender: UIButton) {
        let _parameters = ["id":23, "screen":"changement de langue sur l'ecran des CGU"] as [String : Any]
        Analytics.logEvent("CGU_screen_change_language", parameters: _parameters)
        if LanguageManager.currentLanguage() == "fr" {
            LanguageManager.setCurrentLanguage("ar")
            sender.setTitle("langFR".localized(), for: .normal)
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            LanguageManager.setCurrentLanguage("fr")
            sender.setTitle("langAR".localized(), for: .normal)
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        self.updateWebView()
        LanguageManager.loopThroughSubViewAndReAddThem()
    }
    
}
