//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 26/06/2023.
//

import Foundation

public enum SmilesOnboardingEndPoints: String, CaseIterable {
    
    case getOtpForMobileNumber
    case verifyOtp
    case getProfileStatus
    case loginAsGuest
    case authenticateTouchId
    case getOtpForEmail
    case verifyOtpForEmail
    case emailVerificationStatus

}

extension SmilesOnboardingEndPoints {
    var serviceEndPoints: String {
        switch self {
        
        case .getOtpForMobileNumber:
            return "login/send-otp-v1"
        case .verifyOtp:
            return "login/verify-otp"
        case .getProfileStatus:
            return "login/get-profile-status"
        case .loginAsGuest:
            return "login/login-guest-user"
        case .authenticateTouchId:
            return "profile/enable-touch-id"
        case .getOtpForEmail:
            return "login/send-email-otp"
        case .verifyOtpForEmail:
            return "login/verify-email-otp"
        case .emailVerificationStatus:
            return "login/get-email-verification-status"
        }
    }
}
