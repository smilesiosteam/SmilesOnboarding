//
//  File.swift
//  
//
//  Created by Ahmed Naguib on 17/10/2023.
//

import Foundation
import SmilesBaseMainRequestManager

final class OTPEmailValidationRequest: SmilesBaseMainRequest {
    var captcha: String?
    var deviceCheckToken: String?
    var appAttestation: String?
    var challenge: String?
    var email: String?
    
    init(email: String?) {
        super.init()
        self.email = email
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    enum CodingKeys: String, CodingKey {
        case email
        case captcha
        case deviceCheckToken = "integrityToken"
        case appAttestation
        case challenge
    }
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.captcha, forKey: .captcha)
        try container.encodeIfPresent(self.deviceCheckToken, forKey: .deviceCheckToken)
        try container.encodeIfPresent(self.appAttestation, forKey: .appAttestation)
        try container.encodeIfPresent(self.challenge, forKey: .challenge)
        try container.encodeIfPresent(self.email, forKey: .email)
    }
}
