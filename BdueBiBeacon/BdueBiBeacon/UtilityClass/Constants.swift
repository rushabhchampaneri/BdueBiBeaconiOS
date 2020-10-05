//
//  Constants.swift
//  BdueBiBeacon
//
//  Created by Iottive on 22/10/19.
//  Copyright © 2019 BdueBiBeacon. All rights reserved.
//

import UIKit

let kALERT_TITLE = "BdueBiBeacon"
let kALERT_TITLE_ERROR = "Error"

let kALERT_CHECK_INTERNET_CONNECTION = "Please check internet connection"

class Constants: NSObject {

}

func showAlert(strTitle : String, strMessage : String, viewController : UIViewController){
    let alertController = UIAlertController.init(title: strTitle, message: strMessage, preferredStyle: .alert)
    alertController.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: { action in
        viewController.dismiss(animated: true, completion: nil)
    }))
    viewController.present(alertController, animated: true, completion: nil)
}

func showAlertAndPopToViewController(strTitle : String, strMessage : String, viewController : UIViewController){
    let alertController = UIAlertController.init(title: strTitle, message: strMessage, preferredStyle: .alert)
    alertController.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: { action in
        viewController.dismiss(animated: true, completion: nil)
        viewController.navigationController?.popViewController(animated: true)
    }))
    viewController.present(alertController, animated: true, completion: nil)
}


/* Validate an email for the right format
 There’s some text before the @
 There’s some text after the @
 There’s at least 2 alpha characters after a . */
func isValidEmail(email: String) -> Bool {
    let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", regEx)
    return emailPredicate.evaluate(with: email)
}

/* Validate an password for the right format
 There’s at least one uppercase letter
 There’s at least one lowercase letter
 There’s at least one numeric digit
 The text is at least 8 characters long
 */
func isValidPassword(password: String) -> Bool {
    // at least one uppercase, at least one digit, at least one lowercase, min 8 characters
    let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}")
    return passwordPredicate.evaluate(with: password)
}

