//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 05/07/2023.
//

import Foundation
import SmilesUtilities
import SmilesBaseMainRequestManager

public class VerifyOtpRequest: SmilesBaseMainRequest {
    
    var otp: String?
    var email: String?
    var mobile: String?
    
    init(otp: String?, mobile: String? = nil) {
        super.init()
        self.otp = otp
        self.mobile = mobile
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    
    enum CodingKeys: String, CodingKey {
        case otp
        case email
        case msisdn
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.otp, forKey: .otp)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.mobile, forKey: .msisdn)
    }
}
