//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 03/07/2023.
//

import Foundation
import SmilesUtilities
import SmilesBaseMainRequestManager

public class OTPValidtionRequest: SmilesBaseMainRequest {

    public var captcha: String?
    public var deviceCheckToken: String?
    public var appAttestation: String?
    public var challenge: String?
    public var isNewAPICall: String?
    public var email: String?
    
    init(captcha: String? = "", deviceCheckToken: String? = "", appAttestation: String? = "", challenge: String? = "") {
        super.init()
        self.captcha = captcha
        self.deviceCheckToken = deviceCheckToken
        self.appAttestation = appAttestation
        self.challenge = challenge
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    
    enum CodingKeys: String, CodingKey {
        case captcha
        case deviceCheckToken = "integrityToken"
        case appAttestation
        case challenge
        case isNewAPICall
        case email
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.captcha, forKey: .captcha)
        try container.encodeIfPresent(self.deviceCheckToken, forKey: .deviceCheckToken)
        try container.encodeIfPresent(self.appAttestation, forKey: .appAttestation)
        try container.encodeIfPresent(self.challenge, forKey: .challenge)
        try container.encodeIfPresent(self.isNewAPICall, forKey: .isNewAPICall)
        try container.encodeIfPresent(self.email, forKey: .email)
    }
}
