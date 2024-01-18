//
//  FullAccessLoginResponse.swift
//  House
//
//  Created by Ghullam  Abbas on 18/01/2024.
//  Copyright © 2024 Ahmed samir ali. All rights reserved.
//

import Foundation
import NetworkingLayer

public class FullAccessLoginResponse : BaseMainResponse {
    
    public  let authToken : String?
    public  let msisdn : String?
    public  let limitExceededTitle: String?
    public  let limitExceededMsg: String?
    
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
