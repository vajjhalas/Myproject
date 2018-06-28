//
//  IMEIHistoryModel.swift
//  ACDCSwift
//
//  Created by Pervacio on 26/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import Foundation

struct HistoryRecord {
    var acdcSessionId : String = ""
    var sessionStatus : String = ""
    var sessionStage : String = ""
    var userId : String = ""
    var storeRepId : String = ""
    var imei : String = ""
    var programUsed : String = ""
    var chamberRetryAttempts : String = ""
    var imagecapturedtime : String = ""
    var chamberId : String = ""
    var storeid : String = ""
    var admServerUsed : String = ""
    var admNetworkVersion : String = ""
    var acdcApplicationVersion : String = ""
    var acdcFirmvareVersion : String = ""
    var overallResult : String = ""
    var startDateTime : String = ""
    var endDateTime : String = ""
    var customerRating : String = ""
    var operatorRating : String = ""
    var evaluationAccepted : String = ""
    var deviceExchanged : String = ""
    var additionalInfo : String = ""
    var storeLocation: String = ""
    
    init(json: [String : Any]) {
        self.acdcSessionId = getHistoryRecordInString(jsonString: json["acdcSessionId"] ?? "")
        self.sessionStatus = getHistoryRecordInString(jsonString: json["sessionStatus"] ?? "")
        self.sessionStage = getHistoryRecordInString(jsonString: json["sessionStage"] ?? "")
        self.userId = getHistoryRecordInString(jsonString: json["userId"] ?? "")
        self.storeRepId = getHistoryRecordInString(jsonString: json["storeRepId"] ?? "")
        self.imei = getHistoryRecordInString(jsonString: json["imei"] ?? "")
        self.programUsed = getHistoryRecordInString(jsonString: json["programUsed"] ?? "")
        self.chamberRetryAttempts = getHistoryRecordInString(jsonString: json["chamberRetryAttempts"] ?? "")
        self.imagecapturedtime = getHistoryRecordInString(jsonString: json["imagecapturedtime"] ?? "")
        self.chamberId = getHistoryRecordInString(jsonString: json["chamberId"] ?? "")
        self.storeid = getHistoryRecordInString(jsonString: json["storeid"] ?? "")
        self.admServerUsed = getHistoryRecordInString(jsonString: json["admServerUsed"] ?? "")
        self.admNetworkVersion = getHistoryRecordInString(jsonString: json["admNetworkVersion"] ?? "")
        self.acdcApplicationVersion = getHistoryRecordInString(jsonString: json["acdcApplicationVersion"] ?? "")
        self.acdcFirmvareVersion = getHistoryRecordInString(jsonString: json["acdcFirmvareVersion"] ?? "")
        self.overallResult = getHistoryRecordInString(jsonString: json["overallResult"] ?? "")
        self.startDateTime = getHistoryRecordInString(jsonString: json["startDateTime"] ?? "")
        self.endDateTime = getHistoryRecordInString(jsonString: json["endDateTime"] ?? "")
        self.customerRating = getHistoryRecordInString(jsonString: json["customerRating"] ?? "")
        self.operatorRating = getHistoryRecordInString(jsonString: json["operatorRating"] ?? "")
        self.evaluationAccepted = getHistoryRecordInString(jsonString: json["evaluationAccepted"] ?? "")
        self.deviceExchanged = getHistoryRecordInString(jsonString: json["deviceExchanged"] ?? "")
        self.additionalInfo = getHistoryRecordInString(jsonString: json["additionalInfo"] ?? "")
        self.storeLocation = getHistoryRecordInString(jsonString: json["storeLocation"] ?? "")
    }
    
    func getHistoryRecordInString(jsonString: Any) -> String {
        let stringValue : String?
        if jsonString is String {
            stringValue = jsonString as! String
        } else if jsonString is NSNumber {
            stringValue = (jsonString as! NSNumber).stringValue
        } else {
            stringValue = ""
        }
        return stringValue!
    }
}
