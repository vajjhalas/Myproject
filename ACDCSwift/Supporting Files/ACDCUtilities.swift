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
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
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
