//
//  PermissionsViewController.swift
//  Wiqaytna

import UIKit
import UserNotifications
import Firebase

class PermissionsViewController: UIViewController {
    
    @IBOutlet weak var switchLanguageLabel: UIButton!
    @IBOutlet weak var PermissionTitle: UILabel!
    @IBOutlet weak var PermissionSubTitle: UILabel!
    @IBOutlet weak var PermissionBluetoothP: UILabel!
    @IBOutlet weak var PermissionBluetoothA: UILabel!
    @IBOutlet weak var PermissionNotifications: UILabel!
    @IBOutlet weak var PermissionButtonNext: UIButton!    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _parameters = ["id":4, "screen":"ecran des permission"] as [String : Any]
        Analytics.logEvent("setup_screen", parameters: _parameters)
        updateText()
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Show the navigation bar on other view controllers
    }
    
    @objc func updateText() {
        
        let _PermissionButtonNext = "PermissionButtonNext".localized()
        
        PermissionTitle.text = "PermissionTitle".localized()
        PermissionSubTitle.text = "PermissionSubTitle".localized()
        PermissionBluetoothP.text = "PermissionBluetoothP".localized()
        PermissionBluetoothA.text = "PermissionBluetoothA".localized()
        PermissionNotifications.text = "PermissionNotifications".localized()
        PermissionButtonNext.setTitle(_PermissionButtonNext.capitalized, for: .normal)
        
        switchLanguageLabel.setTitle(LanguageManager.currentLanguage() == "fr" ? "langAR".localized() : "langFR".localized(), for: .normal)
    }
    
    //MARK: Actions
    @IBAction func allowPermissionsBtn(_ sender: UIButton) {
        BluetraceManager.shared.turnOn()
        registerForPushNotifications()
        
        OnboardingManager.shared.completedIWantToHelp = true
        OnboardingManager.shared.hasConsented = true
        OnboardingManager.shared.allowedPermissions = true
        OnboardingManager.shared.completedBluetoothOnboarding = true
        
        let blePoweredOn = BluetraceManager.shared.isBluetoothOn()
        let bleAuthorized = BluetraceManager.shared.isBluetoothAuthorized()
        
        BlueTraceLocalNotifications.shared.checkAuthorization { (granted) in
            if granted && blePoweredOn && bleAuthorized {
                self.performSegue(withIdentifier: "showFullySetUpFromTurnOnBtSegue", sender: self)
            }
            else {
                self.performSegue(withIdentifier: "showFullySetUpFromTurnOnBtSegue", sender: self) // showHomeFromTurnOnBtSegue
            }
        }
        
    }
    
    @IBAction func switchLanguage(_ sender: UIButton) {
        if LanguageManager.currentLanguage() == "fr" {
            LanguageManager.setCurrentLanguage("ar")
            sender.setTitle("langFR".localized(), for: .normal)
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            LanguageManager.setCurrentLanguage("fr")
            sender.setTitle("langAR".localized(), for: .normal)
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        LanguageManager.loopThroughSubViewAndReAddThem()
    }
    
    func registerForPushNotifications() {
        BlueTraceLocalNotifications.shared.checkAuthorization { (_) in
            //Make updates to VCs if any here.
        }
    }
    
}
