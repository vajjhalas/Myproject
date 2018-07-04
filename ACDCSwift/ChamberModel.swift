//
//  ChamberModel.swift
//  ACDCSwift
//
//  Created by Pervacio on 04/07/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import Foundation

struct Chamber {
    
//    var chamberConfig: [String:Any]
//    var chamberID: String
//    var chamberDisplayName: String
//    var chmaberStatus : String
//    
//    init(jsonRecord: [String: Any]) {
//
//        chamberConfig = (jsonRecord["chamberConfig"] as? [String: Any]) ?? ["":""]
//        chamberID = jsonRecord["chamberId"] ?? ""
//        chamberDisplayName = jsonRecord["chamberId"] ?? ""
//
//    }
    
}


struct ChamberInfo {
    var chamberName : String = ""
    var chamberStatus : String = ""
    var chamberIdentifier : String = ""
    var chamberConfig: [String:Any]
    
    init(jsonRecord : [String: Any]) {
        chamberName = jsonRecord["displayName"] as? String ?? ""
        chamberStatus = jsonRecord["status"] as? String ?? ""
        if jsonRecord["chamberId"] is String {
            chamberIdentifier = (jsonRecord["chamberId"] as! String)
        } else if jsonRecord["chamberId"] is NSNumber {
            chamberIdentifier = (jsonRecord["chamberId"] as! NSNumber).stringValue
        } else {
            chamberIdentifier = ""
        }
        
        chamberConfig = (jsonRecord["chamberConfig"] as? [String: Any]) ?? ["":""]
        
    }
}
