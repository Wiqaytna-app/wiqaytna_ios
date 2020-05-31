//
//  TracerRemoteConfig.swift
//  Wiqaytna
//
//  Created by MAC PRO on 09/05/2020.
//  Copyright © 2020 Wiqaytna. All rights reserved.
//

import Foundation
import FirebaseRemoteConfig

struct TracerRemoteConfig {
   
    static private(set) var instance: RemoteConfig!
    static let defaultShareText = "ShareMessage".localized()
    
    init() {
        // Setup remote config
        TracerRemoteConfig.instance = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600
        TracerRemoteConfig.instance.configSettings = settings
        
        let defaultValue = ["ShareText": TracerRemoteConfig.defaultShareText as NSObject]
        TracerRemoteConfig.instance.setDefaults(defaultValue)
        TracerRemoteConfig.instance.fetch(withExpirationDuration: TimeInterval(3600)) { (status, error) -> Void in
            if status == .success {
                Logger.DLog("Remote config fetch success")
                TracerRemoteConfig.instance.activate { (error) in
                    Logger.DLog("Remote config activate\(error == nil ? "" : " with error \(error!)")")
                }
            } else {
                Logger.DLog("Config not fetched")
                Logger.DLog("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
}
