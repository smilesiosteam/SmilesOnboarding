//
//  File.swift
//  
//
//  Created by Ahmed Naguib on 20/12/2023.
//

import Foundation
import NetworkingLayer

final class EmailVerificationStatusResponse: BaseMainResponse {
    let extTransactionID, email: String?
    let isExistingCustomer: Bool?
    let hintMessage: String?

    enum CodingKeys: String, CodingKey {
        case extTransactionID = "extTransactionId"
        case email, isExistingCustomer, hintMessage
    }
    
    required  init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        extTransactionID = try values.decodeIfPresent(String.self, forKey: .extTransactionID)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        isExistingCustomer = try values.decodeIfPresent(Bool.self, forKey: .isExistingCustomer)
        hintMessage = try values.decodeIfPresent(String.self, forKey: .hintMessage)
        try super.init(from: decoder)
    }
}
