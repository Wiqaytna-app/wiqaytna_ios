//
//  SettingsRepository.swift
//  Wiqaytna
//
//  Created by MAC PRO on 03/05/2020.
//  Copyright © 2020 Wiqaytna. All rights reserved.
//

import Foundation

class SettingsRepository {
    
    enum Key {
        case age, gender, region, province, regionID, provinceID, regionObj, provinceObj
    }
    
    let userDefaults: UserDefaults
    // MARK: - Lifecycle
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    // MARK: - API
    func storeAge(age: String) {
        saveParam(forKey: .age, value: age)
    }
    
    func storeGender(gender: String) {
        saveParam(forKey: .gender, value: gender)
    }
    
    func storeRegion(region: String) {
        saveParam(forKey: .region, value: region)
    }
    
    func storeProvince(province: String) {
        saveParam(forKey: .province, value: province)
    }
    
    func storeRegionID(regionID: String) {
        saveParam(forKey: .regionID, value: regionID)
    }
    
    func storeProvinceID(provinceID: String) {
        saveParam(forKey: .provinceID, value: provinceID)
    }
    
    func storeRegionObj(regionObj: Dictionary<String, Any>) {
        saveParam(forKey: .regionObj, value: regionObj)
    }
    
    func storeProvinceObj(provinceObj: Dictionary<String, Any>) {
        saveParam(forKey: .provinceObj, value: provinceObj)
    }
    
    func fetchAge() -> Any? {
        return readParam(forKey: .age)
    }
    
    func fetchGender() -> Any? {
        return readParam(forKey: .gender)
    }
    
    func fetchRegion() -> Any? {
        return readParam(forKey: .region)
    }
    
    func fetchProvince() -> Any? {
        return readParam(forKey: .province)
    }
    
    func fetchRegionID() -> Any? {
        return readParam(forKey: .regionID)
    }
    
    func fetchProvinceID() -> Any? {
        return readParam(forKey: .provinceID)
    }
    
    func fetchRegionObj() -> Any? {
        return readParam(forKey: .regionObj)
    }
    
    func fetchProvinceObj() -> Any? {
        return readParam(forKey: .provinceObj)
    }
    
    // MARK: - Private
    private func saveParam(forKey key: Key, value: Any) {
        
        var keyToSave: String = ""
        switch key {
        case .age:
            keyToSave = "SH_SETT_AGE"
        case .gender:
            keyToSave = "SH_SETT_GENDER"
        case .region:
            keyToSave = "SH_SETT_REGION"
        case .province:
            keyToSave = "SH_SETT_PROVINCE"
        case .regionID:
            keyToSave = "SH_SETT_REGION_ID"
        case .provinceID:
            keyToSave = "SH_SETT_PROVINCE_ID"
        case .regionObj:
            keyToSave = "SH_SETT_REGION_OBJ"
        case .provinceObj:
            keyToSave = "SH_SETT_PROVINCE_OBJ"
        }
        
        userDefaults.set(value, forKey: keyToSave)
    }
    
    private func readParam(forKey key: Key) -> Any? {
        
        var keyToSave: String = ""
        switch key {
        case .age:
            keyToSave = "SH_SETT_AGE"
        case .gender:
            keyToSave = "SH_SETT_GENDER"
        case .region:
            keyToSave = "SH_SETT_REGION"
        case .province:
            keyToSave = "SH_SETT_PROVINCE"
        case .regionID:
            keyToSave = "SH_SETT_REGION_ID"
        case .provinceID:
            keyToSave = "SH_SETT_PROVINCE_ID"
        case .regionObj:
            keyToSave = "SH_SETT_REGION_OBJ"
        case .provinceObj:
            keyToSave = "SH_SETT_PROVINCE_OBJ"
        }
        return userDefaults.value(forKey: keyToSave)
    }
}
