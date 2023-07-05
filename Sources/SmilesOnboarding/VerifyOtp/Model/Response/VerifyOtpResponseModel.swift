//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 04/07/2023.
//

import Foundation
import NetworkingLayer

class VerifyOtpResponseModel : BaseMainResponse {
    
    let authToken : String?
    let msisdn : String?
    let limitExceededTitle: String?
    let limitExceededMsg: String?
    
    enum FullAccessLoginCodingKeys: String, CodingKey {
        case authToken = "authToken"
        case msisdn = "msisdn"
        case limitExceededTitle = "limitExceededTitle"
        case limitExceededMsg = "limitExceededMsg"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: FullAccessLoginCodingKeys.self)
        authToken = try values.decodeIfPresent(String.self, forKey: .authToken)
        msisdn = try values.decodeIfPresent(String.self, forKey: .msisdn)
        limitExceededTitle = try values.decodeIfPresent(String.self, forKey: .limitExceededTitle)
        limitExceededMsg = try values.decodeIfPresent(String.self, forKey: .limitExceededMsg)
        
        try super.init(from: decoder)
    }
    
}


