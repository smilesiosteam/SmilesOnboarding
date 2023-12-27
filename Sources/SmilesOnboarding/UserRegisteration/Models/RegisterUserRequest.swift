//
//  RegisterUserRequest.swift
//  
//
//  Created by Shmeel Ahmed on 26/06/2023.
//


import Foundation
import SmilesBaseMainRequestManager

public class RegisterUserRequest: SmilesBaseMainRequest {

    var birthDate : String?
    var email : String?
    var firstName : String?
    var gender : String?
    var lastName : String?
    var nationality : String?
    var referralCode : String?
    var isExistingUser = false
    var skipEmailVerification: Bool?
    
    enum CodingKeys: String, CodingKey {
        case birthDate = "birthDate"
        case email = "email"
        case firstName = "firstName"
        case gender = "gender"
        case lastName = "lastName"
        case nationality = "nationality"
        case referralCode = "referralCode"
        case dateOfBirth = "dateOfBirth"
        case skipEmailVerification = "skipEmailVerification"
    }
    
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    public override init() {
        super.init()
    }
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.birthDate, forKey: !isExistingUser ? .birthDate : .dateOfBirth)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.firstName, forKey: .firstName)
        try container.encodeIfPresent(self.gender, forKey: .gender)
        try container.encodeIfPresent(self.lastName, forKey: .lastName)
        try container.encodeIfPresent(self.nationality, forKey: .nationality)
        try container.encodeIfPresent(self.referralCode, forKey: .referralCode)
        try container.encodeIfPresent(self.skipEmailVerification, forKey: .skipEmailVerification)
    }
}
