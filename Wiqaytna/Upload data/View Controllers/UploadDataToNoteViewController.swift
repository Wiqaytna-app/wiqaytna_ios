//
//  UploadDataToNoteViewController.swift
//  Wiqaytna

import UIKit
import Firebase

class UploadDataToNoteViewController: UIViewController {
    @IBOutlet weak var UploadTitle: UILabel!
    @IBOutlet weak var UploadSubTitle: UILabel!
    @IBOutlet weak var buttonNext: UIButton!
    @IBOutlet weak var navigationBar: UITabBarItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _parameters = ["id":10, "screen":"premier écran de l'upload manuel"] as [String : Any]
        Analytics.logEvent("upload_screen_1", parameters: _parameters)
        updateText()
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
    }

    @objc func updateText() {
        navigationBar.title = "BarBottomUpload".localized()
        UploadTitle.text = "UploadTitle".localized()
        UploadSubTitle.text = "UploadSubTitle".localized()
        buttonNext.setTitle("ButtonNext".localized(), for: .normal)
    }
    
}
