//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 05/07/2023.
//

import Foundation
import NetworkingLayer

class GuestUserResponseModel: BaseMainResponse {
    
    let guestSessionDetails: GuestUserAuthToken?
    
    enum CreateOtpCodingKeys: String, CodingKey {
        case guestSessionDetails = "guestSessionDetails"
    }
    
    required  init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CreateOtpCodingKeys.self)
        guestSessionDetails = try values.decodeIfPresent(GuestUserAuthToken.self, forKey: .guestSessionDetails)
        try super.init(from: decoder)
    }
}

class GuestUserAuthToken: BaseMainResponse {
    
    let authToken: String?
    
    enum CreateOtpCodingKeys: String, CodingKey {
        case authToken = "authToken"
    }
    
    required  init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CreateOtpCodingKeys.self)
        authToken = try values.decodeIfPresent(String.self, forKey: .authToken)
        try super.init(from: decoder)
    }
}
