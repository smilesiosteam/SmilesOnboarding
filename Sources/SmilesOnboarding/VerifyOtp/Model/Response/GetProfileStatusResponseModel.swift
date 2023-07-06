//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 05/07/2023.
//

import Foundation
import NetworkingLayer


public class GetProfileStatusResponse : BaseMainResponse {
    
    public let profileStatus : Int?
    
    enum ProfileStatusCodingKeys: String, CodingKey {
        case profileStatus = "profileStatus"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ProfileStatusCodingKeys.self)
        profileStatus = try values.decodeIfPresent(Int.self, forKey: .profileStatus)
        try super.init(from: decoder)
    }
    
}
