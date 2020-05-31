//
//  PogoInstructionsViewController.swift
//  Wiqaytna

import UIKit
import Firebase

class PogoInstructionsViewController: UIViewController {
    
    @IBOutlet weak var SavePowerTitle: UILabel!
    @IBOutlet weak var SavePowerSubTitle: UILabel!
    @IBOutlet weak var SavePowerInfo: UILabel!
    @IBOutlet weak var SavePowerInfoOne: UILabel!
    @IBOutlet weak var SavePowerIntoTwo: UILabel!
    @IBOutlet weak var SavePowerNote: UILabel!
    @IBOutlet weak var SavePowerNextButton: UIButton!
    @IBOutlet weak var buttonSwitchLanguage: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _parameters = ["id":17, "screen":"écran pour les utilisateurs iPhone"] as [String : Any]
        Analytics.logEvent("power_saver", parameters: _parameters)
        updateText()
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
    }
    
    @objc func updateText() {
        
        let _SavePowerNextButton = "SavePowerNextButton".localized()
        
        SavePowerTitle.text = "SavePowerTitle".localized()
        SavePowerSubTitle.text = "SavePowerSubTitle".localized()
        SavePowerInfo.text = "SavePowerInfo".localized()
        SavePowerInfoOne.text = "SavePowerInfoOne".localized()
        SavePowerIntoTwo.text = "SavePowerIntoTwo".localized()
        SavePowerNote.text = "SavePowerNote".localized()
        SavePowerNextButton.setTitle(_SavePowerNextButton, for: .normal)
        
        buttonSwitchLanguage.setTitle(LanguageManager.currentLanguage() == "fr" ? "langAR".localized() : "langFR".localized(), for: .normal)
    }
    
    func navigationToVC(_ screen: String) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let ScreenVC = storyboard.instantiateViewController(withIdentifier: screen)
        self.navigationController?.pushViewController(ScreenVC, animated: false)
    }
    
    //MARK: Actions
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
    
    
    @IBAction func navigationButton(_ sender: UIButton) {
        let firstLaunch = UserDefaults.standard.bool(forKey: "firstLaunch")
        if firstLaunch  {
            print("Not first launch. TRUE")
            navigationToVC("main")
        } else {
            print("First launch. FALSE")
            navigationToVC("SettingsPage")
        }
    }
}
