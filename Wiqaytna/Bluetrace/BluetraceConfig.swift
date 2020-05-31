//
//  BluetraceConfig.swift
//  Wiqaytna

import CoreBluetooth

import Foundation

struct BluetraceConfig {
    
    // To obtain the official BlueTrace Service ID and Characteristic ID, please email info@bluetrace.io
    static let BluetoothServiceID = CBUUID(string: "ADD_SERVICE_ID")

    // Staging and Prod uses the same CharacteristicServiceIDv2, since BluetoothServiceID is different
    static let CharacteristicServiceIDv2 = CBUUID(string: "ADD_CHARACTERISTICS_SERVICE_IDV2")

    static let OrgID = "MAR"
    static let ProtocolVersion = 2

    static let CentralScanInterval = 60 // in seconds
    static let CentralScanDuration = 10 // in seconds

    static let TTLDays = -21
}
