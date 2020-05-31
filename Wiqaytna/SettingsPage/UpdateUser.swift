//
//  UpdateUser.swift
//  Wiqaytna
//
//  Created by ABDELAZiZ on 4/28/20.
//  Copyright © 2020 Wiqaytna  . All rights reserved.
//

import Foundation
import FirebaseFunctions

class UpdateUser {
    
    // [START functions_instance]
    static var functions = Functions.functions(region: FirebaseConfig.region)
    // [END functions_instance]
    
    static func setUser(age:String, province:String, region:String, gender:String, regionID: String, provinceID: String, lang:String, callBack: @escaping ([String: Any], Bool) -> Void){
        NSLog("setUser called")
        let data = [
            "age": age,
            "proviceID": provinceID,
            "regionID": regionID,
            "gender": gender,
            "lang": lang
        ]
        UpdateUser.functions.httpsCallable("updateUser").call(data) { (result, error) in
          // [START function_error]
          if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
              let code = FunctionsErrorCode(rawValue: error.code)
              let message = error.localizedDescription
              let details = error.userInfo[FunctionsErrorDetailsKey]
            }
            // [START_EXCLUDE]
            print("setUser Error :")
            print(error.localizedDescription)
            callBack([:],false)
            return
            // [END_EXCLUDE]
          }
          // [END function_error]
          if let operationResult = result?.data as? [String : Any] {
              print("setUser success :")
              print(operationResult)
            callBack(operationResult, true)
            
          }
        }
        // [END function_add_numbers]
    }
    
}
