//
//  BleManager.swift
//  BdueBiBeacon
//
//  Created by Bhavik Patel on 05/10/20.
//


import UIKit
import CoreBluetooth
import CoreLocation

enum kErrorCode:Int{
    case bluetoothOff = 0
    case bluetoothNotSupported = 1
    case locationNotEnabled = 2
    case locationAlwaysNeeded = 3
}

let kERR_MSG = "message"

let kERR_MSG_BLUETOOTH_OFF = "Please turn on bluetooth"
let kERR_MSG_ENABLE_LOCATION = "Please enable location"
let kERR_PLEASE_CHANGE_LOCATION_PERMISSION_TO_ALWAYS = "Please change location permission to always"

//iBeacon Manager Closure
public typealias OnBeaconFoundBlock = ( _ error: NSError? , _ iBeacon : CLBeacon?) -> Void

public class BleManager: NSObject,CBPeripheralManagerDelegate {
    
    public var objOnBeaconFoundBlock : OnBeaconFoundBlock?
    var bluetoothPeripheralManager: CBPeripheralManager!
    var intBluetoothState : Int! = 0
    var arrRegionUUID : [String] = []
    public static let sharedInstance:BleManager = {
        let instance = BleManager()
        return instance
    }()
    
    override init() {
        super.init()
        iBeaconActor.sharedInstance
        self.bluetoothPeripheralManager = CBPeripheralManager.init(delegate: self, queue: nil)
    }
    
    //MARK:- iBeacon Methods -
    public func startBeaconScanningDevices(arrUUID : [String] , completion : @escaping OnBeaconFoundBlock) {
        self.objOnBeaconFoundBlock = completion
        self.arrRegionUUID = arrUUID
        if self.intBluetoothState == 0 {
            //Wait for bluetooth permission
        } else if self.intBluetoothState != 1 {
            completion(NSError.init(domain: "BdueBiBeacon", code: kErrorCode.bluetoothOff.rawValue, userInfo: [kERR_MSG : kERR_MSG_BLUETOOTH_OFF]), nil)
        } else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            print("authorizedAlways")
            iBeaconActor.sharedInstance.startMonitoringBeacon(arrUUID: arrUUID)
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            print("authorizedWhenInUse")
            completion(NSError.init(domain: "BdueBiBeacon", code: kErrorCode.locationAlwaysNeeded.rawValue, userInfo: [kERR_MSG : kERR_PLEASE_CHANGE_LOCATION_PERMISSION_TO_ALWAYS]), nil)
        } else if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
            print("restricted")
            completion(NSError.init(domain: "BdueBiBeacon", code: kErrorCode.locationNotEnabled.rawValue, userInfo: [kERR_MSG : kERR_MSG_ENABLE_LOCATION]), nil)
        }
    }
    
    func resetBeaconScanning() {
        if self.intBluetoothState != 1 {
            if self.objOnBeaconFoundBlock != nil {
                self.objOnBeaconFoundBlock!(NSError.init(domain: "BdueBiBeacon", code: kErrorCode.bluetoothOff.rawValue, userInfo: [kERR_MSG : kERR_MSG_BLUETOOTH_OFF]), nil)
            }
        } else if CLLocationManager.authorizationStatus() == .authorizedAlways {
            print("authorizedAlways")
            iBeaconActor.sharedInstance.startMonitoringBeacon(arrUUID: self.arrRegionUUID)
        } else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            print("authorizedWhenInUse")
            if self.objOnBeaconFoundBlock != nil {
                self.objOnBeaconFoundBlock!(NSError.init(domain: "BdueBiBeacon", code: kErrorCode.locationAlwaysNeeded.rawValue, userInfo: [kERR_MSG : kERR_PLEASE_CHANGE_LOCATION_PERMISSION_TO_ALWAYS]), nil)
            }
        } else if CLLocationManager.authorizationStatus() == .denied || CLLocationManager.authorizationStatus() == .restricted {
            print("restricted")
            if self.objOnBeaconFoundBlock != nil {
                self.objOnBeaconFoundBlock!(NSError.init(domain: "BdueBiBeacon", code: kErrorCode.locationNotEnabled.rawValue, userInfo: [kERR_MSG : kERR_MSG_ENABLE_LOCATION]), nil)
            }
        }
    }

    public func stopBeaconScanningDevice() {
        iBeaconActor.sharedInstance.stopMonitoringBeacon()
    }
    
    //MARK:- CBPeripharal manager delegate methods -
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            self.intBluetoothState = 1
        } else {
            self.intBluetoothState = 2
        }
        self.resetBeaconScanning()
    }
}
