//
//  UploadDataStep2VC.swift
//  Wiqaytna

import Foundation
import UIKit
import Firebase
import FirebaseFunctions
import CoreData

class UploadDataStep2VC: UIViewController {
    @IBOutlet weak var disclaimerTextLbl: UILabel!
    @IBOutlet weak var codeInputView: CodeInputView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var uploadErrorMsgLbl: UILabel!
    
    @IBOutlet weak var UploadTitleCodePin: UILabel!
    @IBOutlet weak var UploadConditionUpload: UILabel!
    @IBOutlet weak var buttonUploadData: UIButton!
    
    var functions = Functions.functions(region: FirebaseConfig.region)

    let storageUrl = PlistHelper.getvalueFromInfoPlist(withKey: "FIREBASE_STORAGE_URL") ?? ""

    override func viewDidLoad() {
        disclaimerTextLbl.semiBold(text: "We don’t collect any geolocation or personal data.")
        codeInputView.keyboardType = .asciiCapableNumberPad
        //_ = codeInputView.becomeFirstResponder()
        dismissKeyboardOnTap()
        
        updateText()
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
    }

    @IBAction func backBtnTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func updateText() {
        UploadTitleCodePin.text = "UploadTitleCodePin".localized()
        UploadConditionUpload.text = "UploadConditionUpload".localized()
        buttonUploadData.setTitle("buttonUploadData".localized().capitalized, for: .normal)
        if LanguageManager.currentLanguage() == "ar" {
            UploadTitleCodePin.textAlignment = .right
            UploadConditionUpload.textAlignment = .right
        }else {
            UploadTitleCodePin.textAlignment = .left
            UploadConditionUpload.textAlignment = .left
        }
    }

    
    @IBAction func uploadDataBtnTapped(_ sender: UIButton) {
        sender.isEnabled = false
        self.uploadErrorMsgLbl.isHidden = true
        let code = codeInputView.text
        if code.count < 6 {
            
            self.uploadErrorMsgLbl.text = "NotAValidCode".localized()
            self.uploadErrorMsgLbl.isHidden = false
            sender.isEnabled = true
            return
        }
        
        activityIndicator.startAnimating()
        functions.httpsCallable("getUploadToken").call(code) { [unowned self] (result, error) in
           
            if let error = error as NSError? {
                
                sender.isEnabled = true
                self.activityIndicator.stopAnimating()
                
                self.uploadErrorMsgLbl.isHidden = false
                if error.code == 3 {
                    self.uploadErrorMsgLbl.text = "NotAValidCode".localized()
                    return
                }
                self.uploadErrorMsgLbl.text = "Upload failed".localized()
                return
            }
            
            if let token = (result?.data as? [String: Any])?["token"] as? String {
                self.uploadFile(token: token) { success in
                    sender.isEnabled = true
                    self.activityIndicator.stopAnimating()
                    if success {
                        self.codeInputView.text = ""
                        self.performSegue(withIdentifier: "showSuccessVCSegue", sender: nil)
                    } else {
                        self.uploadErrorMsgLbl.isHidden = false
                        self.uploadErrorMsgLbl.text = "Upload failed".localized()
                    }
                }
                
            } else {
                self.activityIndicator.stopAnimating()
                self.uploadErrorMsgLbl.isHidden = false
                self.uploadErrorMsgLbl.text = "Upload failed".localized()
                sender.isEnabled = true
            }
        }
    }

    func uploadFile(token: String, _ result: @escaping (Bool) -> Void) {
        let manufacturer = "Apple"
        let model = DeviceInfo.getModel().replacingOccurrences(of: " ", with: "")

        let date: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let todayDate = dateFormatter.string(from: date)

        let file = "StreetPassRecord_\(manufacturer)_\(model)_\(todayDate).json"

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let recordsFetchRequest: NSFetchRequest<Encounter> = Encounter.fetchRequestForRecords()
        let eventsFetchRequest: NSFetchRequest<Encounter> = Encounter.fetchRequestForEvents()

        managedContext.perform { [unowned self] in
            guard let records = try? recordsFetchRequest.execute() else {
                Logger.DLog("Error fetching records")
                result(false)
                return
            }

            guard let events = try? eventsFetchRequest.execute() else {
                Logger.DLog("Error fetching events")
                result(false)
                return
            }

            let data = UploadFileData(token: token, records: records, events: events)

            let encoder = JSONEncoder()
            guard let json = try? encoder.encode(data) else {
                Logger.DLog("Error serializing data")
                result(false)
                return
            }

            guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                Logger.DLog("Error locating user documents directory")
                result(false)
                return
            }

            let fileURL = directory.appendingPathComponent(file)

            do {
                try json.write(to: fileURL, options: [])
            } catch {
                Logger.DLog("Error writing to file")
                result(false)
                return
            }

            let fileRef = Storage.storage(url: self.storageUrl).reference().child("streetPassRecords/\(file)")

            _ = fileRef.putFile(from: fileURL, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    Logger.DLog("Error uploading file - \(String(describing: error))")
                    result(false)
                    return
                }

                let size = metadata.size

                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    Logger.DLog("Error deleting uploaded file on local device")
                }

                Logger.DLog("File uploaded [\(size)]")
                result(true)
            }
        }
    }
}
