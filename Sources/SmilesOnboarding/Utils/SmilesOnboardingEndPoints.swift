//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 26/06/2023.
//

import Foundation

public enum SmilesOnboardingEndPoints: String, CaseIterable {
    case getCountries
    case getCaptcha
    case getOtpForMobileNumber
    case verifyOtp
    case getProfileStatus
    case loginAsGuest
}

extension SmilesOnboardingEndPoints {
    var serviceEndPoints: String {
        switch self {
        case .getCountries:
            return "home/get-country-list-v2"
        case .getCaptcha:
            return "login/v2/get-captcha"
        case .getOtpForMobileNumber:
            return "login/send-otp-v1"
        case .verifyOtp:
            return "login/verify-otp"
        case .getProfileStatus:
            return "login/get-profile-status"
        case .loginAsGuest:
            return "login/login-guest-user"
        }
    }
}
