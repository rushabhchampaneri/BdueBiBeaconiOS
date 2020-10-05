//
//  ViewController.swift
//  BdueBiBeacon
//
//  Created by Bhavik Patel on 05/10/20.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //need to call this method and send list of uuid for ibeacon scanning
        self.startBeaconScanning(arrUUID: ["f94dbb23-2266-7822-3782-57beac0952ac"])
    }
    
    //start ibeacon scanning
    func startBeaconScanning(arrUUID : [String]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("----------------beacon scanning started from home screen -------------------")
            BleManager.sharedInstance.startBeaconScanningDevices(arrUUID: arrUUID) { (error, beacon) in
                if error != nil {
                    self.showAlertAndRedirectToSetting(error: error)
                } else {
                    let strBeaconId = String.init("\(beacon?.uuid.uuidString ?? "")_\(beacon?.major ?? 0)_\(beacon?.minor ?? 0)").lowercased()
                    print("beacon discovered \(strBeaconId) rssi : \(String(describing: beacon?.rssi))")
                }
            }
        }
    }
    
    func stopBeaconScanning() {
        BleManager.sharedInstance.stopBeaconScanningDevice()
    }
    
    func showAlertAndRedirectToSetting(error : NSError?) {
        let alertController = UIAlertController.init(title: kALERT_TITLE_ERROR, message: error?.userInfo[kERR_MSG] as? String ?? (error?.localizedDescription)!, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: { action in
            if error?.code == 2 || error?.code == 3 {
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                //redirect setting for permission
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}

