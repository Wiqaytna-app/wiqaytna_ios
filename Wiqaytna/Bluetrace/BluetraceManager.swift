import UIKit
import CoreData
import CoreBluetooth

class BluetraceManager {

    private var peripheralController: PeripheralController!
    private var centralController: CentralController!

    var queue: DispatchQueue!
    var bluetoothDidUpdateStateCallback: ((CBManagerState) -> Void)?

    static let shared = BluetraceManager()

    private init() {
        queue = DispatchQueue(label: "BluetraceManager")
        peripheralController = PeripheralController(peripheralName: "TR", queue: queue)
        centralController = CentralController(queue: queue)
        centralController.centralDidUpdateStateCallback = centralDidUpdateStateCallback
    }

    func turnOn() {
        peripheralController.turnOn()
        centralController.turnOn()
    }

    func getCentralStateText() -> String {
        guard centralController.getState() != nil else {
            return "nil"
        }
        return BluetraceUtils.managerStateToString(centralController.getState()!)
    }

    func getPeripheralStateText() -> String {
        return BluetraceUtils.managerStateToString(peripheralController.getState())
    }

    func isBluetoothAuthorized() -> Bool {
        if #available(iOS 13.1, *) {
            return CBManager.authorization == .allowedAlways
        } else {
            // todo: consider iOS 13.0, which has different behavior from 13.1 onwards
            return CBPeripheralManager.authorizationStatus() == .authorized
        }
    }

    func isBluetoothOn() -> Bool {
        return centralController.getState() == CBManagerState.poweredOn
    }

    func centralDidUpdateStateCallback(_ state: CBManagerState) {
        bluetoothDidUpdateStateCallback?(state)
    }

    func toggleAdvertisement(_ state: Bool) {
        if state {
            peripheralController.turnOn()
        } else {
            peripheralController.turnOff()
        }
    }

    func toggleScanning(_ state: Bool) {
        if state {
            centralController.turnOn()
        } else {
            centralController.turnOff()
        }
    }
}
