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

    init(otp: String?) {
        super.init()
        self.otp = otp
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    
    enum CodingKeys: String, CodingKey {
        case otp
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.otp, forKey: .otp)
    }
}
