//
//  IMEIHistoryModel.swift
//  ACDCSwift
//
//  Created by Pervacio on 26/06/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import Foundation

struct HistoryRecord: Decodable {
    var acdcSessionId : Int = 0
    var sessionStatus : String = ""
    var sessionStage : String = ""
    var userId : String = ""
    var storeRepId : String = ""
    var imei : String = ""
    var programUsed : String = ""
    var chamberRetryAttempts : String = ""
    var imagecapturedtime : Int = 0
    var chamberId : String = ""
    var storeid : String = ""
    var admServerUsed : String = ""
    var admNetworkVersion : String = ""
    var acdcApplicationVersion : String = ""
    var acdcFirmvareVersion : String = ""
    var overallResult : String = ""
    var startDateTime : String = ""
    var endDateTime : String = ""
    var customerRating : Int = 0
    var operatorRating : Int = 0
    var evaluationAccepted : String = ""
    var deviceExchanged : String = ""
    var additionalInfo : String = ""
    var storeLocation: String = ""
    
    enum HistoryStructKeys: String, CodingKey {
        case acdcSessionId = "acdcSessionId"
        case sessionStatus = "sessionStatus"
        case sessionStage = "sessionStage"
        case userId = "userId"
        case storeRepId = "storeRepId"
        case imei = "imei"
        case programUsed = "programUsed"
        case chamberRetryAttempts = "chamberRetryAttempts"
        case imagecapturedtime = "imagecapturedtime"
        case chamberId = "chamberId"
        case storeid = "storeid"
        case admServerUsed = "admServerUsed"
        case admNetworkVersion = "admNetworkVersion"
        case acdcApplicationVersion = "acdcApplicationVersion"
        case acdcFirmvareVersion = "acdcFirmvareVersion"
        case overallResult = "overallResult"
        case startDateTime = "startDateTime"
        case endDateTime = "endDateTime"
        case customerRating = "customerRating"
        case operatorRating = "operatorRating"
        case evaluationAccepted = "evaluationAccepted"
        case deviceExchanged = "deviceExchanged"
        case additionalInfo = "additionalInfo"
        case storeLocation = "storeLocation"
    }
    
    init(acdcSessionId: Int, sessionStatus: String, sessionStage: String, userId: String, storeRepId: String, imei: String, programUsed: String, chamberRetryAttempts: String, imagecapturedtime: Int, chamberId: String, storeid: String, admServerUsed: String, admNetworkVersion: String, acdcApplicationVersion: String, acdcFirmvareVersion: String, overallResult: String, startDateTime: String, endDateTime: String, customerRating: Int, operatorRating: Int, evaluationAccepted: String, deviceExchanged: String, additionalInfo: String, storeLocation: String) {
        self.acdcSessionId = acdcSessionId
        self.sessionStatus = sessionStatus
        self.sessionStage = sessionStage
        self.userId = userId
        self.storeRepId = storeRepId
        self.imei = imei
        self.programUsed = programUsed
        self.chamberRetryAttempts = chamberRetryAttempts
        self.imagecapturedtime = imagecapturedtime
        self.chamberId = chamberId
        self.storeid = storeid
        self.admServerUsed = admServerUsed
        self.admNetworkVersion = admNetworkVersion
        self.acdcApplicationVersion = acdcApplicationVersion
        self.acdcFirmvareVersion = acdcFirmvareVersion
        self.overallResult = overallResult
        self.startDateTime = startDateTime
        self.endDateTime = endDateTime
        self.customerRating = customerRating
        self.operatorRating = operatorRating
        self.evaluationAccepted = evaluationAccepted
        self.deviceExchanged = deviceExchanged
        self.additionalInfo = additionalInfo
        self.storeLocation = storeLocation
    }
    //init  the structure
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: HistoryStructKeys.self)
        let acdcSessionId = try container.decodeIfPresent(Int.self, forKey: .acdcSessionId)
        let sessionStatus = try container.decodeIfPresent(String.self, forKey: .sessionStatus)
        let sessionStage = try container.decodeIfPresent(String.self, forKey: .sessionStage)
        let userId = try container.decodeIfPresent(String.self, forKey: .userId)
        let storeRepId = try container.decodeIfPresent(String.self, forKey: .storeRepId)
        let imei = try container.decodeIfPresent(String.self, forKey: .imei)
        let programUsed = try container.decodeIfPresent(String.self, forKey: .programUsed)
        let chamberRetryAttempts = try container.decodeIfPresent(String.self, forKey: .chamberRetryAttempts)
        let imagecapturedtime = try container.decodeIfPresent(Int.self, forKey: .imagecapturedtime)
        let chamberId = try container.decodeIfPresent(String.self, forKey: .chamberId)
        let storeid = try container.decodeIfPresent(String.self, forKey: .storeid)
        let admServerUsed = try container.decodeIfPresent(String.self, forKey: .admServerUsed)
        let admNetworkVersion = try container.decodeIfPresent(String.self, forKey: .admNetworkVersion)
        let acdcApplicationVersion = try container.decodeIfPresent(String.self, forKey: .acdcApplicationVersion)
        let acdcFirmvareVersion = try container.decodeIfPresent(String.self, forKey: .acdcFirmvareVersion)
        let overallResult = try container.decodeIfPresent(String.self, forKey: .overallResult)
        let startDateTime = try container.decodeIfPresent(String.self, forKey: .startDateTime)
        let endDateTime = try container.decodeIfPresent(String.self, forKey: .endDateTime)
        let customerRating = try container.decodeIfPresent(Int.self, forKey: .customerRating)
        let operatorRating = try container.decodeIfPresent(Int.self, forKey: .operatorRating)
        let evaluationAccepted = try container.decodeIfPresent(String.self, forKey: .evaluationAccepted)
        let deviceExchanged = try container.decodeIfPresent(String.self, forKey: .deviceExchanged)
        let additionalInfo = try container.decodeIfPresent(String.self, forKey: .additionalInfo)
        let storeLocation = try container.decodeIfPresent(String.self, forKey: .storeLocation)
        
        self.init(acdcSessionId: acdcSessionId ?? 0, sessionStatus: sessionStatus ?? "", sessionStage: sessionStage ?? "", userId: userId ?? "", storeRepId: storeRepId ?? "", imei: imei ?? "", programUsed: programUsed ?? "", chamberRetryAttempts: chamberRetryAttempts ?? "", imagecapturedtime: imagecapturedtime ?? 0, chamberId: chamberId ?? "", storeid: storeid ?? "", admServerUsed: admServerUsed ?? "", admNetworkVersion: admNetworkVersion ?? "", acdcApplicationVersion: acdcApplicationVersion ?? "", acdcFirmvareVersion: acdcFirmvareVersion ?? "", overallResult: overallResult ?? "", startDateTime: startDateTime ?? "", endDateTime: endDateTime ?? "", customerRating: customerRating ?? 0, operatorRating: operatorRating ?? 0, evaluationAccepted: evaluationAccepted ?? "", deviceExchanged: deviceExchanged ?? "", additionalInfo: additionalInfo ?? "", storeLocation: storeLocation ?? "")
    }
}
