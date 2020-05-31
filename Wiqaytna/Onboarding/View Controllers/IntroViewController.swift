//
//  IntroViewController.swift
//  Wiqaytna

import UIKit
import SafariServices
import Firebase

class IntroViewController: UIViewController {
    
    @IBOutlet var langButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var conditionsTitle: UILabel!
    @IBOutlet weak var conditionTitleTwo: UILabel!
    @IBOutlet weak var conditionTitleThree: UILabel!
    @IBOutlet weak var conditionLink: UIButton!
    @IBOutlet weak var buttonAccept: UIButton!
    @IBOutlet weak var conditionTitleOne: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _parameters = ["id":1, "screen":"premier ecran d'onboarding"] as [String : Any]
        Analytics.logEvent("first_screen", parameters: _parameters)
        updateText()
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
    }
    
    
    @objc func updateText() {
        titleLabel.text = "IntroCovidTitle".localized()
        conditionsTitle.text = "IntroConditionsTitle".localized()
        conditionTitleOne.text = "IntroConditionsOne".localized()
        conditionTitleTwo.text = "IntroConditionsTwo".localized()
        conditionTitleThree.text = "IntroConditionsThree".localized()
        conditionLink.setTitle("IntroConditionsLink".localized(), for: .normal)
        buttonAccept.setTitle("IntroJeVeuxAider".localized().capitalized, for: .normal)
        
        conditionLink.titleLabel?.numberOfLines = 0
        conditionLink.contentHorizontalAlignment = .left
        if LanguageManager.currentLanguage() == "ar" {
            conditionLink.contentHorizontalAlignment = .right
        }
        
        langButton.setTitle(LanguageManager.currentLanguage() == "fr" ? "langAR".localized() : "langFR".localized(), for: .normal)
    }
    
    //MARK: Actions
    @IBAction func privacyBtn(_ sender: UIButton) {
        guard let url = URL(string: "") else {
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    
    
    @IBAction func buttnLanguage(_ sender: UIButton) {
        let _parameters = ["id":19, "screen":"changement de langue sur le premier écran d'onboarding"] as [String : Any]
        Analytics.logEvent("first_screen_change_language", parameters: _parameters)

        if LanguageManager.currentLanguage() == "fr" {
            LanguageManager.setCurrentLanguage("ar")
            langButton.setTitle("langFR".localized(), for: .normal)
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else {
            LanguageManager.setCurrentLanguage("fr")
            langButton.setTitle("langAR".localized(), for: .normal)
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        LanguageManager.loopThroughSubViewAndReAddThem()
    }
}

extension IntroViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
