//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 03/07/2023.
//

import Foundation
import NetworkingLayer

// MARK: - CAPTCHAResponseModel
class CaptchaResponseModel: BaseMainResponse {
    var captchaDetails: CAPTCHADetails?
    var limitExceededTitle : String?
    var limitExceededMsg : String?
    
    enum CodingKeys: String, CodingKey {
        case captchaDetails
        case limitExceededTitle
        case limitExceededMsg
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        captchaDetails = try values.decodeIfPresent(CAPTCHADetails.self, forKey: .captchaDetails)
        limitExceededTitle = try values.decodeIfPresent(String.self, forKey: .limitExceededTitle)
        limitExceededMsg = try values.decodeIfPresent(String.self, forKey: .limitExceededMsg)
        try super.init(from: decoder)
    }
}

class CAPTCHADetails: BaseMainResponse {
    var captcha: String?
    var captchaExpiry: Double?
    
    enum CodingKeys: String, CodingKey {
        case captcha
        case captchaExpiry
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        captcha = try values.decodeIfPresent(String.self, forKey: .captcha)
        captchaExpiry = try values.decodeIfPresent(Double.self, forKey: .captchaExpiry)
        try super.init(from: decoder)
    }
}

