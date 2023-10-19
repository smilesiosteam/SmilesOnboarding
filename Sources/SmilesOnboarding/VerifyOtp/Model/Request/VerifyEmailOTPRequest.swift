//
//  File.swift
//  
//
//  Created by Ahmed Naguib on 18/10/2023.
//

import Foundation


import Foundation
import SmilesUtilities
import SmilesBaseMainRequestManager

public class VerifyEmailOTPRequest: SmilesBaseMainRequest {
    
    var otp: String?
    var email: String?
    
    init(otp: String?, email: String?) {
        super.init()
        self.otp = otp
        self.email = email
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    
    enum CodingKeys: String, CodingKey {
        case otp
        case email
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.otp, forKey: .otp)
        try container.encodeIfPresent(self.email, forKey: .email)
    }
}
