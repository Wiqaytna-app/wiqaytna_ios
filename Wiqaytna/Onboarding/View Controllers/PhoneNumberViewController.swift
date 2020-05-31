import UIKit
import FirebaseAuth
import FirebaseFunctions
import Firebase

class PhoneNumberViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var getOTPButton: UIButton!
    @IBOutlet weak var smsTitle: UILabel!
    @IBOutlet weak var smsLabelTextField: UILabel!
    @IBOutlet weak var smsNote: UILabel!
    @IBOutlet weak var switchLanguageLabel: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var ViewForm: UIView!
    
    let MIN_PHONE_LENGTH = 9
    let PHONE_NUMBER_LENGTH = 10
    static var functions = Functions.functions(region: FirebaseConfig.region)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _parameters = ["id":2, "screen":"ecran de saisi du numéro du téléphone"] as [String : Any]
        Analytics.logEvent("phone_number_screen", parameters: _parameters)
        self.phoneNumberField.addTarget(self, action: #selector(self.phoneNumberFieldDidChange), for: UIControl.Event.editingChanged)
        self.phoneNumberField.keyboardType = .asciiCapableNumberPad
        self.phoneNumberFieldDidChange()
        phoneNumberField.delegate = self
        dismissKeyboardOnTap()
        updateText()
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
    }
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        getOTPButton.isEnabled = false
        verifyPhoneNumberAndProceed(self.phoneNumberField.text ?? "")
    }
    
    @objc
    func phoneNumberFieldDidChange() {
        guard let text = self.phoneNumberField.text, !text.isEmpty else {
            self.getOTPButton.isEnabled = false; return
        }
        
        self.getOTPButton.isEnabled = text.count >= MIN_PHONE_LENGTH
        if text.count == PHONE_NUMBER_LENGTH {
            self.phoneNumberField.resignFirstResponder()
        }
    }
    
    func verifyPhoneNumberAndProceed(_ mobileNumber: String) {
        
        var phoneNumber = mobileNumber
        if phoneNumber.prefix(1) == "0" {
            phoneNumber = String(phoneNumber.dropFirst(1))
        }
        
        guard phoneNumber.isValidNumber else {
            let alert = UIAlertController(title: "Error".localized(), message: "invalid_number".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        activityIndicator.startAnimating()
        self.view.bringSubviewToFront(activityIndicator)
        let phoneNumberWithCountryCode = "+212\(phoneNumber)"
        
        Auth.auth().signInAnonymously() { (authResult, error) in
            guard let user = authResult?.user else {
                return
            }
            
            let uid = user.uid
            let firebaseToken = UserDefaults.standard.string(forKey: "firebaseToken")
            
            UserDefaults.standard.set(uid, forKey: "authVerificationID")
            UserDefaults.standard.set(phoneNumberWithCountryCode, forKey: "mobileNumber")
            
            let data = [
                "os": "IOS",
                "phoneNumber": phoneNumberWithCountryCode,
                "token": firebaseToken
            ]
            
            PhoneNumberViewController.functions.httpsCallable("getOTPCode").call(data) { (result, error) in
                if let _ = error as NSError? {
                    return
                }
            }
            self.performSegue(withIdentifier: "segueFromNumberToOTP", sender: self)
            self.activityIndicator.stopAnimating()
        }
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let newLength = textField.text?.count ?? 0 + string.count
        return newLength <= PHONE_NUMBER_LENGTH
    }
    
    @objc func updateText() {
        smsTitle.text = "SmsTitle".localized()
        smsLabelTextField.text = "SmsLabelTextField".localized()
        smsNote.text = "SmsNote".localized()
        getOTPButton.setTitle("SmsButtonSend".localized().capitalized, for: .normal)
        switchLanguageLabel.setTitle(LanguageManager.currentLanguage() == "fr" ? "langAR".localized() : "langFR".localized(), for: .normal)
        
        ViewForm.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    }
    
    @IBAction func switchLanguageAction(_ sender: UIButton) {
        let _parameters = ["id":20, "screen":"changement de langue sur l'ecran de saisi du numéro du téléphone"] as [String : Any]
        Analytics.logEvent("phone_number_screen_change_language", parameters: _parameters)
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
}

extension String {
    
    var isValidNumber: Bool {
        return self.matches("^[6-7]\\d{8}$")
    }
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    func chopPrefix(_ count: Int = 1) -> String {
        return String(self.prefix(count))
    }
}
