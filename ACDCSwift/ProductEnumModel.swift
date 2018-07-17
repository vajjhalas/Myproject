//
//  ProductEnumModel.swift
//  ACDCSwift
//
//  Created by Pervacio on 16/07/18.
//  Copyright © 2018 Pervacio. All rights reserved.
//

import Foundation

enum ACDC_Product: String {
    //Or may be we can reverse case names and raw value
case BUYERS_REMORSE = "BUYERS REMORSE"
case WARRANTY_EXCHANGE = "WARRANTY EXCHANGE"
    case TRADE_IN = "TRADE IN"
case JUMP = "JUMP"
case JUMP_ON_DEMAND = "JUMP ON DEMAND"
    
    var caseName: String {
        return String(describing: self)
    }
    
   
}

extension String {
    
    func fetchProductName() -> String {
        
        switch self {
            
        case ACDC_Product.BUYERS_REMORSE.caseName:
            
            return ACDC_Product.BUYERS_REMORSE.rawValue
            
        case ACDC_Product.WARRANTY_EXCHANGE.caseName:
            return ACDC_Product.WARRANTY_EXCHANGE.rawValue
            
        case ACDC_Product.TRADE_IN.caseName:
            return ACDC_Product.TRADE_IN.rawValue
        
        case ACDC_Product.JUMP.caseName:
            return ACDC_Product.JUMP.rawValue
            
        case ACDC_Product.JUMP_ON_DEMAND.caseName:
            return ACDC_Product.JUMP_ON_DEMAND.rawValue
            
        default:
            return self
        }
    }
    
}
