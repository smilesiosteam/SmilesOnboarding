//
//  VerifyUserDetailsResponse.swift
//  
//
//  Created by Shmeel Ahmed on 26/06/2023.
//

import Foundation

import Foundation
import NetworkingLayer
import SmilesUtilities

public class VerifyUserDetailsResponse : BaseMainResponse {
    
    let isValid : Bool?
    let isVerified : Bool?
    let responseDesc : String?
    
    
    enum verifyLoginDetailsCodingKeys: String, CodingKey {
        case isValid = "isValid"
        case isVerified = "isVerified"
        case responseDesc = "responseDesc"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: verifyLoginDetailsCodingKeys.self)
        isValid = try values.decodeIfPresent(Bool.self, forKey: .isValid)
        isVerified = try values.decodeIfPresent(Bool.self, forKey: .isVerified)
        responseDesc = try values.decodeIfPresent(String.self, forKey: .responseDesc)
        try super.init(from: decoder)
    }
}
