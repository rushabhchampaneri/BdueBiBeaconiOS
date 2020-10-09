//
//  iBeaconActor.swift
//  BdueBiBeacon
//
//  Created by Bhavik Patel on 05/10/20.
//


import UIKit
import CoreLocation

public class iBeaconActor: NSObject,CLLocationManagerDelegate {
    
    let beaconRegionIdentifier = "BdueBiBeacon"
    let beaconUUID = "f94dbb23-2266-7822-3782-57beac0952ac"
    
    //MARK:- Variable Declaration -
    public let objLocationManager = CLLocationManager()
    //MARK:- Initilizers -
    public static let sharedInstance:iBeaconActor = {
        let instance = iBeaconActor()
        return instance
    }()
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    //MARK:- Custom Methods -
    public func setupLocationManager() {
        objLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        objLocationManager.distanceFilter = 500.0
        objLocationManager.delegate = self
        objLocationManager.allowsBackgroundLocationUpdates = true
        objLocationManager.pausesLocationUpdatesAutomatically = false
        objLocationManager.requestAlwaysAuthorization()
    }
    
    public func startMonitoringBeacon(arrUUID : [String]) {
        print("-------------beacon scanning started ------------")
        objLocationManager.startUpdatingLocation()
        for strUUID in arrUUID {
            let uuid = NSUUID(uuidString: strUUID)! as UUID
            let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: strUUID)
            beaconRegion.notifyEntryStateOnDisplay = true
            beaconRegion.notifyOnExit = true
            beaconRegion.notifyOnEntry = true
            objLocationManager.startMonitoring(for: beaconRegion)
            objLocationManager.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: uuid))
        }
        appDelegate_.sendLocalNotification(strTitle: "Beacon", strMessage: "Start Scanning")
    }
    
    func stopMonitoringBeacon() {
        print("-------------beacon scanning stopped ------------")
        appDelegate_.sendLocalNotification(strTitle: "Beacon", strMessage: "stop Scanning")
        objLocationManager.stopUpdatingLocation()
        for strUUID in BleManager.sharedInstance.arrRegionUUID {
            let uuid = NSUUID(uuidString: strUUID)! as UUID
            let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: strUUID)
            objLocationManager.stopMonitoring(for: beaconRegion)
            objLocationManager.stopRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: uuid))
        }
    }
    
    //MARK: - CLLocationManagerDelegate Methods
    public func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("didExitRegion ----------------")
        var responseData : [String : Any] = [:]
        if BleManager.sharedInstance.currentLocation != nil {
            responseData = [kResponseType : 2 ,klat : BleManager.sharedInstance.currentLocation?.coordinate.latitude ?? 0 , klng : BleManager.sharedInstance.currentLocation?.coordinate.longitude ?? 0]
        } else {
            responseData = [kResponseType : 2 , klat : 0 , klng : 0]
        }
        BleManager.sharedInstance.objOnBeaconFoundBlock!(nil, responseData)
        appDelegate_.sendLocalNotification(strTitle: "Beacon", strMessage: "didExitRegion")
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("didEnterRegion -------------------")
        appDelegate_.sendLocalNotification(strTitle: "Beacon", strMessage: "didEnterRegion")
        var responseData : [String : Any] = [:]
        if BleManager.sharedInstance.currentLocation != nil {
            responseData = [kResponseType : 3 ,klat : BleManager.sharedInstance.currentLocation?.coordinate.latitude ?? 0 , klng : BleManager.sharedInstance.currentLocation?.coordinate.longitude ?? 0]
        } else {
            responseData = [kResponseType : 3 , klat : 0 , klng : 0]
        }
        BleManager.sharedInstance.objOnBeaconFoundBlock!(nil, responseData)
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            if BleManager.sharedInstance.objOnBeaconFoundBlock != nil {
                var arrBeaconList :[[String : Any]] = []
                for beacon in beacons {
                    let dicData : [String : Any] = [kBeaconUUID : beacon.uuid.uuidString, kBeaconMinor : beacon.minor , kBeaconMajor : beacon.major]
                    arrBeaconList.append(dicData)
                }
                
                var responseData : [String : Any] = [:]
                if BleManager.sharedInstance.currentLocation != nil {
                    responseData = [kResponseType : 1 , kBeaconList : arrBeaconList , klat : BleManager.sharedInstance.currentLocation?.coordinate.latitude ?? 0 , klng : BleManager.sharedInstance.currentLocation?.coordinate.longitude ?? 0]
                } else {
                    responseData = [kResponseType : 1 , kBeaconList : arrBeaconList , klat : 0 , klng : 0]
                }
                BleManager.sharedInstance.objOnBeaconFoundBlock!(nil, responseData)
                appDelegate_.sendLocalNotification(strTitle: "Beacon", strMessage: "No Of Beacon Detacted : \(beacons.count)")
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("authorizedAlways")
            self.startMonitoringBeacon(arrUUID: BleManager.sharedInstance.arrRegionUUID)
        } else if status == .authorizedWhenInUse {
            print("authorizedWhenInUse")
            if BleManager.sharedInstance.objOnBeaconFoundBlock != nil {
                BleManager.sharedInstance.objOnBeaconFoundBlock!(NSError.init(domain: "BdueBiBeacon", code: kErrorCode.locationAlwaysNeeded.rawValue, userInfo: [kERR_MSG : kERR_PLEASE_CHANGE_LOCATION_PERMISSION_TO_ALWAYS]), nil)
            }
        } else if status == .denied || status == .restricted  {
            print("restricted")
            if BleManager.sharedInstance.objOnBeaconFoundBlock != nil {
                BleManager.sharedInstance.objOnBeaconFoundBlock!(NSError.init(domain: "BdueBiBeacon", code: kErrorCode.locationNotEnabled.rawValue, userInfo: [kERR_MSG : kERR_MSG_ENABLE_LOCATION]), nil)
            }
        }
        print("did change autorization-------------")
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        var stateString : String!
        
        switch (state) {
        case CLRegionState.inside:
            stateString = "inside"
            break;
        case CLRegionState.outside:
            stateString = "outside"
            break;
        case CLRegionState.unknown:
            stateString = "unknown"
            break;
        }
        print("State changed to --------- \(String(describing: stateString))")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        BleManager.sharedInstance.currentLocation = locations.last
    }
}
