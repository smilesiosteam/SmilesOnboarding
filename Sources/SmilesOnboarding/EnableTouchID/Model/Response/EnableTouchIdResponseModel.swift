//
//  EnableTouchIdResponseModel.swift
//  House
//
//  Created by Shahroze Zaheer on 07/07/2023.
//  Copyright (c) 2023 All rights reserved.
//


import Foundation
import NetworkingLayer
import SmilesUtilities

public class EnableTouchIdResponseModel: BaseMainResponse {
    
    let status : Int?
    
    enum CreateOtpCodingKeys: String, CodingKey {
        case status = "status"
        
    }
    
    required  init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CreateOtpCodingKeys.self)
        status = try values.decodeIfPresent(Int.self, forKey: .status)
        try super.init(from: decoder)
    }
    
    
}
