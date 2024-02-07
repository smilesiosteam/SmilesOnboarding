//
//  File.swift
//  
//
//  Created by Ahmed Naguib on 20/12/2023.
//

import Foundation
import NetworkingLayer

final class EmailVerificationStatusResponse: BaseMainResponse, LimitTimeChecker {
    var limitExceededTitle: String?
    var limitExceededMsg: String?
    var otpHeaderText: String?
    var timeout: Int?
    
    let extTransactionID, email: String?
    let isExistingCustomer: Bool?
    let hintMessage: String?

    enum CodingKeys: String, CodingKey {
        case extTransactionID = "extTransactionId"
        case email, isExistingCustomer, hintMessage
        case timeout = "timeout"
        case limitExceededMsg = "limitExceededMsg"
        case limitExceededTitle = "limitExceededTitle"
        case otpHeaderText = "otpHeaderText"
    }
    
    required  init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        extTransactionID = try values.decodeIfPresent(String.self, forKey: .extTransactionID)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        isExistingCustomer = try values.decodeIfPresent(Bool.self, forKey: .isExistingCustomer)
        hintMessage = try values.decodeIfPresent(String.self, forKey: .hintMessage)
        timeout = try values.decodeIfPresent(Int.self, forKey: .timeout)
        limitExceededTitle = try values.decodeIfPresent(String.self, forKey: .limitExceededTitle)
        limitExceededMsg = try values.decodeIfPresent(String.self, forKey: .limitExceededMsg)
        otpHeaderText = try values.decodeIfPresent(String.self, forKey: .otpHeaderText)
        try super.init(from: decoder)
    }
}
