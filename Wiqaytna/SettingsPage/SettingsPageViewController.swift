//
//  SettingsPageViewController.swift
//  Wiqaytna
//
//  Created by ABDELAZiZ on 4/24/20.
//  Copyright © 2020 Wiqaytna. All rights reserved.
//

import UIKit
import Firebase

class SettingsPageViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var btnAge1040: UIButton!
    @IBOutlet weak var labelBtnAge1840: UIButton!
    @IBOutlet weak var btnAge4060: UIButton!
    @IBOutlet weak var labelBtnAge4060: UIButton!
    @IBOutlet weak var btnAge6070: UIButton!
    @IBOutlet weak var labelBtnAge6070: UIButton!
    @IBOutlet weak var btnAge70100: UIButton!
    @IBOutlet weak var labelBtnAge70100: UIButton!
    @IBOutlet weak var btnFemme: UIButton!
    @IBOutlet weak var labelBtnFemme: UIButton!
    @IBOutlet weak var btnHomme: UIButton!
    @IBOutlet weak var labelBtnHomme: UIButton!
    @IBOutlet weak var labelBtnAR: UIButton!
    @IBOutlet weak var btnAR: UIButton!
    @IBOutlet weak var labelBtnFR: UIButton!
    @IBOutlet weak var btnFR: UIButton!
    
    @IBOutlet weak var pickerTextField: UITextField!
    @IBOutlet weak var pickerProvinceTextField: UITextField!
    
    @IBOutlet weak var SettingsAge: UILabel!
    @IBOutlet weak var SettingsGenre: UILabel!
    @IBOutlet weak var SettingsRegion: UILabel!
    @IBOutlet weak var SettingsProvince: UILabel!
    @IBOutlet weak var SettingsLangue: UILabel!
    @IBOutlet weak var SettingsEnregistrer: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var pickerData: [String] = [String]()
    var _age = "18-40"
    var _ageIndex = 1
    var _genre = "female"
    var _region = ""
    var _langue = "ar"
    var selectedRegID = ""
    var selectedProvID = ""
    var selectedRegStr = ""
    var selectedProvStr = ""
    var selectedRegion: Dictionary<String, Any> = Dictionary<String, Any>()
    var selectedProvince: Dictionary<String, Any> = Dictionary<String, Any>()
    let pickerRegion = UIPickerView()
    let pickerProvince = UIPickerView()
    var regionsArray: [Dictionary<String, Any>] = [Dictionary<String, Any>]()
    let settingsRepo = SettingsRepository()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _parameters = ["id":5, "screen":"ecran paramètres"] as [String : Any]
        Analytics.logEvent("settings_screen", parameters: _parameters)
        setScrollView()
        self.getRegions()
        createPickerView()
        checkLangConfig()
        setPickersToolbar()
        updateText()
        NotificationCenter.default.addObserver(self, selector: #selector(updateText), name: Notification.Name(rawValue: kLanguageChangeNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let storedAge = self.settingsRepo.fetchAge() as? String {
            selectAge(storedAge)
        }
        
        if let storedGender = self.settingsRepo.fetchGender() as? String {
            selectGenre(storedGender)
        }
        
        if let storedRegion = self.settingsRepo.fetchRegion() as? String {
            pickerTextField.text = storedRegion
            selectedRegStr = storedRegion
        }else {
            pickerTextField.text = "---"
        }
        
        if let storedProvince = self.settingsRepo.fetchProvince() as? String {
            pickerProvinceTextField.text = storedProvince
            selectedProvStr = storedProvince
        }else {
            pickerProvinceTextField.text = "---"
        }
        
        if let storedRegionID = self.settingsRepo.fetchRegionID() as? String {
            selectedRegID = storedRegionID
        }
        
        if let storedProvinceID = self.settingsRepo.fetchProvinceID() as? String {
            selectedProvID = storedProvinceID
        }
        
        let language = LanguageManager.currentLanguage()
        if let storedRegionObj = self.settingsRepo.fetchRegionObj() as? Dictionary<String, Any> {
            selectedRegion = storedRegionObj
            if language == "ar" {
                if let regionStr = selectedRegion["region_ar"] as? String {
                    pickerTextField.text = regionStr
                }
            }else {
                if let regionStr = selectedRegion["region_fr"] as? String {
                    pickerTextField.text = regionStr
                }
            }
        }
        
        if let storedProvinceObj = self.settingsRepo.fetchProvinceObj() as? Dictionary<String, Any> {
            selectedProvince = storedProvinceObj
            if language == "ar" {
                if let provinceStr = selectedProvince["province_ar"] as? String {
                    pickerProvinceTextField.text = provinceStr
                }
            }else {
                if let provinceStr = selectedProvince["province_fr"] as? String {
                    pickerProvinceTextField.text = provinceStr
                }
            }
        }
    }
    
    private func setScrollView() {
        
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        stackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    private func getRegions() {
        
        if let path = Bundle.main.path(forResource: "regions", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [Dictionary<String, Any>] {
                    self.regionsArray = jsonResult
                }
            } catch {
                // handle error
            }
        }
    }
    
    @objc func updateText() {
        labelBtnAge1840.setTitle("SettingsDe18a40".localized(), for: .normal)
        labelBtnAge4060.setTitle("SettingsDe40a60".localized(), for: .normal)
        labelBtnAge6070.setTitle("SettingsDe60a70".localized(), for: .normal)
        labelBtnAge70100.setTitle("SettingsDe70a100".localized(), for: .normal)
        labelBtnFemme.setTitle("SettingsFemme".localized(), for: .normal)
        labelBtnHomme.setTitle("SettingsHomme".localized(), for: .normal)
        labelBtnFR.setTitle("SettingsFrançais".localized(), for: .normal)
        labelBtnAR.setTitle("SettingsArabe".localized(), for: .normal)
        
        SettingsAge.text = "SettingsAge".localized()
        SettingsGenre.text = "SettingsGenre".localized()
        SettingsRegion.text = "SettingsRegion".localized()
        SettingsProvince.text = "SettingsProvince".localized()
        SettingsLangue.text = "SettingsLangue".localized()
        
        SettingsEnregistrer.setTitle("SettingsEnregistrer".localized(), for: .normal)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 111 {
            return self.regionsArray.count
        }else {
            if let provincesArray: [Dictionary<String, Any>] = selectedRegion["provinces"] as? [Dictionary<String, Any>] {
                return provincesArray.count
            }else {
                return 0
            }
        }
        //return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let language = LanguageManager.currentLanguage()
        if pickerView.tag == 111 {
            
            let currentRegion = self.regionsArray[row]            
            if language == "ar" {
                let currentRegionStr = currentRegion["region_ar"] as! String                
                return currentRegionStr
            }else {
                let currentRegionStr = currentRegion["region_fr"] as! String
                return currentRegionStr
            }
            
        }else {
            
            let provincesArray: [Dictionary<String, Any>] = selectedRegion["provinces"] as! [Dictionary<String, Any>]
            let currentProvince = provincesArray[row]
            if language == "ar" {
                let currentProvinceStr = currentProvince["province_ar"] as! String
                return currentProvinceStr
            }else {
                let currentProvinceStr = currentProvince["province_fr"] as! String
                return currentProvinceStr
            }
        }
        //        pickerTextField.text = pickerData[row]
        //        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let language = LanguageManager.currentLanguage()
        if pickerView.tag == 111 {
            selectedRegion = self.regionsArray[row]
            var selectedRegionStr = ""
            if language == "ar" {
                selectedRegionStr = selectedRegion["region_ar"] as! String
            }else {
                selectedRegionStr = selectedRegion["region_fr"] as! String
            }
            selectedRegID = selectedRegion["code_region"] as! String
            pickerTextField.text = selectedRegionStr
            selectedRegStr = selectedRegionStr
            selectedProvID = ""
            selectedProvStr = ""
            selectedProvince = Dictionary<String, Any>()
            pickerProvinceTextField.text = "---"
            
        }else {
            
            if let provincesArray: [Dictionary<String, Any>] = selectedRegion["provinces"] as? [Dictionary<String, Any>] {
                
                selectedProvince = provincesArray[row]
                var selectedProvinceStr = ""
                if language == "ar" {
                    selectedProvinceStr = selectedProvince["province_ar"] as! String
                }else {
                    selectedProvinceStr = selectedProvince["province_fr"] as! String
                }
                selectedProvID = selectedProvince["code_province"] as! String
                pickerProvinceTextField.text = selectedProvinceStr
                selectedProvStr = selectedProvinceStr
            }
        }
        
        //pickerTextField.text = pickerData[row]
    }
    
    func createPickerView() {
        pickerRegion.delegate = self
        pickerRegion.tag = 111
        pickerTextField.inputView = pickerRegion
        
        pickerProvince.delegate = self
        pickerProvince.tag = 222
        pickerProvinceTextField.inputView = pickerProvince
    }
    
    
    func setPickersToolbar() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let _title = "Select".localized()
        let button = UIBarButtonItem(title: _title, style: .plain, target: self, action: #selector(self.action))
        toolBar.setItems([button], animated: true)
        toolBar.isUserInteractionEnabled = true
        pickerTextField.inputAccessoryView = toolBar
        pickerProvinceTextField.inputAccessoryView = toolBar
        
    }
    
    @objc func action() {
        _region = pickerTextField.text!
        view.endEditing(true)
    }
    
    func checkLangConfig(){
        let language = LanguageManager.currentLanguage()
        if language == "ar" {
            _langue = "ar"
            btnFR.isSelected = false
            labelBtnFR.isSelected = false
            btnAR.isSelected = true
            labelBtnAR.isSelected = true
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        } else{
            _langue = "fr"
            btnFR.isSelected = true
            labelBtnFR.isSelected = true
            btnAR.isSelected = false
            labelBtnAR.isSelected = false
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        }
        //LanguageManager.loopThroughSubViewAndReAddThem()
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        let firstLaunch = UserDefaults.standard.bool(forKey: "firstLaunch")
        if firstLaunch  {
            //            navigationToVC("main")
            if let nav = self.navigationController {
                nav.popViewController(animated: false)
            } else {
                self.dismiss(animated: false, completion: nil)
            }
        } else {
            UserDefaults.standard.set(true, forKey: "firstLaunch")
            navigationToVC("main")
            //            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func SelectAge18a40(_ sender: Any) {
        selectAge("18-40")
    }
    
    @IBAction func SelectAge40a60(_ sender: Any) {
        selectAge("40-60")
    }
    
    @IBAction func SelectAge60a70(_ sender: Any) {
        selectAge("60-70")
    }
    
    @IBAction func SelectAge70a100(_ sender: Any) {
        selectAge("70-100")
    }
    
    func selectAge(_ age: String) {
        _age = age
        if age == "18-40" {
            _ageIndex = 1
            btnAge1040.isSelected = true
            labelBtnAge1840.isSelected = true
            btnAge4060.isSelected = false
            labelBtnAge4060.isSelected = false
            btnAge6070.isSelected = false
            labelBtnAge6070.isSelected = false
            btnAge70100.isSelected = false
            labelBtnAge70100.isSelected = false
        }
        if age == "40-60" {
            _ageIndex = 2
            btnAge1040.isSelected = false
            labelBtnAge1840.isSelected = false
            btnAge4060.isSelected = true
            labelBtnAge4060.isSelected = true
            btnAge6070.isSelected = false
            labelBtnAge6070.isSelected = false
            btnAge70100.isSelected = false
            labelBtnAge70100.isSelected = false
        }
        if age == "60-70" {
            _ageIndex = 3
            btnAge1040.isSelected = false
            labelBtnAge1840.isSelected = false
            btnAge4060.isSelected = false
            labelBtnAge4060.isSelected = false
            btnAge6070.isSelected = true
            labelBtnAge6070.isSelected = true
            btnAge70100.isSelected = false
            labelBtnAge70100.isSelected = false
        }
        if age == "70-100" {
            _ageIndex = 4
            btnAge1040.isSelected = false
            labelBtnAge1840.isSelected = false
            btnAge4060.isSelected = false
            labelBtnAge4060.isSelected = false
            btnAge6070.isSelected = false
            labelBtnAge6070.isSelected = false
            btnAge70100.isSelected = true
            labelBtnAge70100.isSelected = true
        }
    }
    
    @IBAction func btnLangueFR(_ sender: UIButton) {
        selectLangue("fr")
    }
    
    @IBAction func btnLangueAR(_ sender: UIButton) {
        selectLangue("ar")
    }
    
    func selectLangue(_ langue: String) {
        let _parameters = ["id":22, "screen":"chagement de langue sur l'ecran des permissions"] as [String : Any]
        Analytics.logEvent("setup_screen_change_language", parameters: _parameters)
        _langue = langue
        if langue == "fr" {
            btnFR.isSelected = true
            labelBtnFR.isSelected = true
            btnAR.isSelected = false
            labelBtnAR.isSelected = false
            //LanguageManager.setCurrentLanguage("fr")
            //setPickersToolbar()
        }
        if langue == "ar" {
            btnFR.isSelected = false
            labelBtnFR.isSelected = false
            btnAR.isSelected = true
            labelBtnAR.isSelected = true
            //LanguageManager.setCurrentLanguage("ar")
            //setPickersToolbar()
        }
        //checkLangConfig()
    }
    
    @IBAction func btnGenreFemme(_ sender: UIButton) {
        selectGenre("female")
    }
    @IBAction func btnGenreHomme(_ sender: UIButton) {
        selectGenre("male")
    }
    func selectGenre(_ genre: String) {
        _genre = genre
        if genre == "female" {
            btnFemme.isSelected = true
            labelBtnFemme.isSelected = true
            btnHomme.isSelected = false
            labelBtnHomme.isSelected = false
        }
        if genre == "male" {
            btnFemme.isSelected = false
            labelBtnFemme.isSelected = false
            btnHomme.isSelected = true
            labelBtnHomme.isSelected = true
        }
    }
    
    @IBAction func btnSave(_ sender: UIButton) {
        
        self.activityIndicator.startAnimating()
        self.view.bringSubviewToFront(activityIndicator)
        UpdateUser.setUser(age: String(_ageIndex), province: selectedProvStr, region: selectedRegStr, gender: _genre, regionID: selectedRegID, provinceID: selectedProvID, lang: _langue) { (dataResult,isSuccess) in
            
            self.activityIndicator.stopAnimating()
            if isSuccess {
                //                self.navigationController?.popViewController(animated: true)
                self.settingsRepo.storeAge(age: self._age)
                self.settingsRepo.storeGender(gender: self._genre)
                self.settingsRepo.storeRegion(region: self.selectedRegStr)
                self.settingsRepo.storeProvince(province: self.selectedProvStr)
                self.settingsRepo.storeRegionID(regionID: self.selectedRegID)
                self.settingsRepo.storeProvinceID(provinceID: self.selectedProvID)
                self.settingsRepo.storeRegionObj(regionObj: self.selectedRegion)
                self.settingsRepo.storeProvinceObj(provinceObj: self.selectedProvince)
                
                LanguageManager.setCurrentLanguage(self._langue)
                
                self.navigationToVC("main")
            } else {
                let alert = UIAlertController(title: "Error".localized(), message: "unknown_error".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.navigationController?.present(alert, animated: true, completion: nil)
            }
            
            print(dataResult)
        }
    }
    
    func navigationToVC(_ screen: String) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let ScreenVC = storyboard.instantiateViewController(withIdentifier: screen)
        self.navigationController?.pushViewController(ScreenVC, animated: false)
    }
    
}
