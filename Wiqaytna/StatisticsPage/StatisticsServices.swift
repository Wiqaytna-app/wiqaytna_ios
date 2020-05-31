//
//  StatisticsServices.swift
//  Wiqaytna
//
//  Created by ABDELAZiZ on 4/30/20.
//  Copyright © 2020 Wiqaytna. All rights reserved.
//

import Foundation
import FirebaseFunctions

class StatisticsServices {
    // [START functions_instance]
    static var functions = Functions.functions(region: FirebaseConfig.region)
    // [END functions_instance]
    
   
    static func statistics(callBack: @escaping ([String: Any]) -> Void){

        StatisticsServices.functions.httpsCallable("stats").call{ (result, error) in

          // [START function_error]

          if let error = error as NSError? {

            if error.domain == FunctionsErrorDomain {

              let code = FunctionsErrorCode(rawValue: error.code)

              let message = error.localizedDescription

              let details = error.userInfo[FunctionsErrorDetailsKey]

            }

            // [START_EXCLUDE]

            print(error.localizedDescription)

            callBack([:])

            return

            // [END_EXCLUDE]

          }

          // [END function_error]

          if let operationResult: [String: Any] = result?.data as? [String: Any]{

//             print(operationResult)

            if let resultData: [String: Any]  = operationResult["data"] as? [String: Any] {

                callBack(resultData)

                //print("resultData ------- ")
                //print(resultData)

            }

          }

        }

        // [END function_add_numbers]

    }
        
}
