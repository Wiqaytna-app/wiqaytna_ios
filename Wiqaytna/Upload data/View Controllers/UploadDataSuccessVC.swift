//
//  UploadDataSuccessVC.swift
//  Wiqaytna

import Foundation
import UIKit
import Firebase

class UploadDataSuccessVC: UIViewController {
    @IBOutlet weak var UploadSuccessMessage: UILabel!
    @IBOutlet weak var ButtonDone: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _parameters = ["id":12, "screen":"ecran upload manuel réussi"] as [String : Any]
        Analytics.logEvent("upload_succeeded", parameters: _parameters)
        updateText()
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
    }
    
   @objc func updateText() {
       UploadSuccessMessage.text = "UploadSuccessMessage".localized()
       ButtonDone.setTitle("ButtonDone".localized().capitalized, for: .normal)
   }
   
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        // Bring user back to home tab
        self.navigationController?.tabBarController?.selectedIndex = 0
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kGoBackUploadNotification), object: nil)
    }
    
}
