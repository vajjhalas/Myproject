//
//  PreviewPDFApi.swift
//  ACDCSwift
//
//  Created by Wilfred Furthado M on 03/07/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import Foundation
import AcdcNetwork

class PreviewPDFAPI {
    
    typealias PDFResponse = (Data?, String?) -> (Void)
    
    class  func fetchPDFData(transactionID: String, completion: @escaping PDFResponse)  {
        let acdcRequestAdapter = AcdcNetworkAdapter.shared()
        acdcRequestAdapter.fetchPreview(forTransactionID: transactionID, successCallback: {(statusCode, responseResult) in
            guard let receivedStatusCode = statusCode else {
                //Status code should always exists
                return completion(nil, "Something went wrong. Received bad response.")
            }
            if(receivedStatusCode == 200) {
                guard let dataResponse = responseResult else {
                    return completion(nil, "Something went wrong. Received bad response.")
                }
                do{
                    //parse dataResponse
                    let jsonResponse = try JSONSerialization.jsonObject(with:
                        dataResponse, options: [])
                    guard let parsedResponse = (jsonResponse as? [String : Any]) else {
                        
                        return completion(nil, "Unexpected response received from server.")

                    }
                    guard let pdfString = parsedResponse["data"] as? String else {
                        return completion(nil, "Unexpected response received from server.")
                    }
                     let dataFromServer = Data.init(base64Encoded: pdfString)!
                     return completion(dataFromServer,nil)
                } catch {
                    return completion(nil, "Could not parse response.")
                }
            }else {
                //status code not 200
                if(receivedStatusCode == 401){
                    return completion(nil, "Not Authorized!")
                }
                else if(ACDCResponseStatus.init(statusCode: receivedStatusCode) == .ServerError){
                    return completion(nil, "Server error")
                } else {
                    return completion(nil, "Something went wrong. Received bad response.")
                }
            }
        }) { (error) in
            //Error
            var errorDescription = ""
            if let  errorDes = error?.localizedDescription {
                errorDescription = errorDes
                return completion(nil, errorDescription)
            }
        }
    }
}
