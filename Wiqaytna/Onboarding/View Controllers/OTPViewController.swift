//
//  OTPViewController.swift
//  Wiqaytna

import UIKit
import FirebaseAuth
import FirebaseFunctions
import Firebase

class OTPViewController: UIViewController {
    
    enum Status {
        case InvalidOTP
        case WrongOTP
        case Success
    }
    
    // MARK: - UI
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var codeInputView: CodeInputView?
    @IBOutlet weak var expiredMessageLabel: UILabel?
    @IBOutlet weak var errorMessageLabel: UILabel?
    @IBOutlet weak var errorMessageTitle: UILabel?
    
    @IBOutlet weak var otpLabelTextField: UILabel!
    @IBOutlet weak var wrongNumberButton: UIButton?
    @IBOutlet weak var resendCodeButton: UIButton?
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var switchLanguageTitle: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var timer: Timer?
    
    static let twoMinutes = 120
    static let userDefaultsPinKey = "HEALTH_AUTH_VERIFICATION_CODE"
    
    var countdownSeconds = twoMinutes
    lazy var functions = Functions.functions(region: FirebaseConfig.region)
    
    let linkButtonAttributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Muli", size: 16)!, .foregroundColor: UIColor.blue, .underlineStyle: NSUnderlineStyle.single.rawValue]
    
    lazy var countdownFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _parameters = ["id":3, "screen":"ecran otp de l'onboarding"] as [String : Any]
        Analytics.logEvent("otp_screen", parameters: _parameters)
        let wrongNumberButtonTitle = NSMutableAttributedString(string: NSLocalizedString("WrongNumber", comment: "Wrong number?"), attributes: linkButtonAttributes)
        wrongNumberButton?.setAttributedTitle(wrongNumberButtonTitle, for: .normal)
        expiredMessageLabel?.textColor = .black
        self.codeInputView?.keyboardType = .asciiCapableNumberPad
        dismissKeyboardOnTap()
        
        updateText()
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startTimer()
    }
    
    func setLabelOtp(){
        let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber") ?? "Unknown"
        self.titleLabel.text = String(format: NSLocalizedString("EnterOTPSent", comment: "Enter OTP that was sent to 91234567"), mobileNumber)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = codeInputView?.becomeFirstResponder()
    }
    
    func startTimer() {
        
        countdownSeconds = OTPViewController.twoMinutes
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(OTPViewController.updateTimerCountdown), userInfo: nil, repeats: true)
        errorMessageLabel?.isHidden = true
        errorMessageTitle?.isHidden=true
        verifyButton?.isEnabled = true
        resendCodeButton?.isUserInteractionEnabled = false
    }
    
    @objc
    func updateTimerCountdown() {
        countdownSeconds -= 1
        
        if countdownSeconds > 0 {
            let countdown = countdownFormatter.string(from: TimeInterval(countdownSeconds))!
            expiredMessageLabel?.text = "OtpCodeWillExpired".localized()
            expiredMessageLabel?.textColor = .black
        } else {
            timer?.invalidate()
            expiredMessageLabel?.text = "CodeHasExpired".localized()
            expiredMessageLabel?.textColor = .red
            verifyButton?.isEnabled = false
            resendCodeButton?.isUserInteractionEnabled = true
        }
    }
    
    func verifyOTP(_ result: @escaping (Status) -> Void) {
        
        guard let OTP = codeInputView?.text else {
            result(.InvalidOTP)
            return
        }
        
        guard OTP.range(of: "^[0-9]{6}$", options: .regularExpression) != nil else {
            result(.InvalidOTP)
            return
        }
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
        let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber")
        
        
        // via firebase cloud fucniton*************************************************************************************
        let data = [
            "OTP": OTP
        ]
        
        activityIndicator.startAnimating()
        self.view.bringSubviewToFront(activityIndicator)
        
        self.functions.httpsCallable("verifyOTP").call(data) { (res, error) in
            // [START function_error]
            
            self.activityIndicator.stopAnimating()
            
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    
                }
                // [START_EXCLUDE]
                print(error.localizedDescription)
                return
                // [END_EXCLUDE]
            }
            // [END function_error]
            if let operationResult = res?.data as? Bool{
                if(operationResult){
                    result(.Success)
                    let pin = verificationID.prefix(6)
                    UserDefaults.standard.set(pin, forKey: OTPViewController.userDefaultsPinKey)
                    return
                }else{
                    result(.WrongOTP)
                    return
                }
            }
        }
    }
    
    @objc func updateText() {
        setLabelOtp()
        resendCodeButton!.setTitle("ResendCode".localized(), for: .normal)
        titleLabel.text = "OtpEnterOTPSent".localized()
        otpLabelTextField.text = "OtpLabelTextField".localized()
        expiredMessageLabel?.text = "OtpCodeWillExpired".localized()
        verifyButton.setTitle("OtpButtonVerify".localized().capitalized, for: .normal)
        switchLanguageTitle.setTitle(LanguageManager.currentLanguage() == "en" ? "langAR".localized() : "langFR".localized(), for: .normal)
    }
    
    //MARK: Actions
    @IBAction func resendCode(_ sender: UIButton) {
        let _parameters = ["id":18, "screen":"Click sur le bouton resendOTP sur l'ecran otp"] as [String : Any]
        Analytics.logEvent("otp_screen_resend_otp", parameters: _parameters)
        // via firebase cloud function*************************************************************************************
        let firebaseToken = UserDefaults.standard.string(forKey: "firebaseToken")
        let newNB = UserDefaults.standard.string(forKey: "mobileNumber")
        let data = [
            "phoneNumber": newNB,
            "token": firebaseToken
        ]
        activityIndicator.startAnimating()
        self.view.bringSubviewToFront(activityIndicator)
        self.functions.httpsCallable("resendOTP").call(data) { (result, error) in
            // [START function_error]
            self.activityIndicator.stopAnimating()
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    
                }
                // [START_EXCLUDE]
                print(error.localizedDescription)
                return
                // [END_EXCLUDE]
            }
            // [END function_error]
            if let operationResult = result?.data{
                
                if let otpValue = (operationResult as AnyObject)["OTP"] {
                    print("OTP:: \(otpValue)")
                }
            }
        }
        // [END function_add_numbers]
        startTimer()
    }
    
    @IBAction func switchLanguage(_ sender: UIButton) {
        let _parameters = ["id":21, "screen":"changement de langue sur l'ecran otp de l'onboarding"] as [String : Any]
        Analytics.logEvent("otp_screen_change_language", parameters: _parameters)
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
    
    @IBAction func verify(_ sender: UIButton) {
        verifyOTP { [unowned viewController = self] status in
            switch status {
            case .InvalidOTP:
                viewController.errorMessageLabel?.text = "InvalidOTP".localized() // NSLocalizedString("InvalidOTP", comment: "Must be a 6-digit code")
                self.errorMessageLabel?.isHidden = false
            //                self.errorMessageTitle?.isHidden = false
            case .WrongOTP:
                viewController.errorMessageLabel?.text = "InvalidOTP".localized() // NSLocalizedString("WrongOTP", comment: "Wrong OTP entered")
                self.errorMessageTitle?.isHidden = false
                self.errorMessageLabel?.isHidden = false
            case .Success:
                DispatchQueue.main.async {
                    if !UserDefaults.standard.bool(forKey: "hasConsented") {
                        viewController.performSegue(withIdentifier: "showConsentFromOTPSegue", sender: self)
                    } else if !UserDefaults.standard.bool(forKey: "allowedPermissions") {
                        viewController.performSegue(withIdentifier: "showAllowPermissionsFromOTPSegue", sender: self)
                    } else if !UserDefaults.standard.bool(forKey: "completedBluetoothOnboarding") {
                        self.performSegue(withIdentifier: "OTPToTurnOnBtSegue", sender: self)
                    } else {
                        self.performSegue(withIdentifier: "OTPToHomeSegue", sender: self)
                    }
                }
            }
        }
    }
}
