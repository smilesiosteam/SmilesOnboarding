//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 03/07/2023.
//

import Foundation
import NetworkingLayer

final class CreateOtpResponse: BaseMainResponse, LimitTimeChecker {
    var timeout: Int?
    var limitExceededTitle : String?
    var limitExceededMsg : String?
    var otpHeaderText: String?
    
    enum CreateOtpCodingKeys: String, CodingKey {
        case timeout = "timeout"
        case limitExceededMsg = "limitExceededMsg"
        case limitExceededTitle = "limitExceededTitle"
        case otpHeaderText = "otpHeaderText"
        
        
    }
    
    required  init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CreateOtpCodingKeys.self)
        timeout = try values.decodeIfPresent(Int.self, forKey: .timeout)
        limitExceededTitle = try values.decodeIfPresent(String.self, forKey: .limitExceededTitle)
        limitExceededMsg = try values.decodeIfPresent(String.self, forKey: .limitExceededMsg)
        otpHeaderText = try values.decodeIfPresent(String.self, forKey: .otpHeaderText)

        try super.init(from: decoder)
    }
    
    
}
 
