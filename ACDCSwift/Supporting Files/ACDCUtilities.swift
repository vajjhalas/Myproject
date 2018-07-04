//
//  ACDCUtilities.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 29/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import Foundation
import UIKit

class ACDCUtilities {
    static func showMessage(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    static func isValidPhoneNumber(phoneNumber: String)->Bool {
        let phoneNumb = phoneNumber
        if self.isAllDigits(phoneNumber: phoneNumb) == true {
            let phoneRegex = "[235689][0-9]{6}([0-9]{3})?"
            let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return  predicate.evaluate(with: phoneNumber)
        }else {
            return false
        }
    }
    
    static func isAllDigits(phoneNumber: String)->Bool {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = phoneNumber.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  phoneNumber == filtered
    }
    
    static func isValidEmailId(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}

extension UIApplication {
    static func topViewController(base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

enum ACDCResponseStatus {
    case Informational
    case Success
    case Redirection
    case ClientError
    case ServerError
    case Undefined
    
    public init(statusCode: Int) {
        switch statusCode {
        case 100 ..< 200:
            self = .Informational
        case 200 ..< 300:
            self = .Success
        case 300 ..< 400:
            self = .Redirection
        case 400 ..< 500:
            self = .ClientError
        case 500 ..< 600:
            self = .ServerError
        default:
            self = .Undefined
        }
    }
}



