//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 04/07/2023.
//

import Foundation

extension VerifyOtpViewModel {
    enum Input {
        case verifyOtp(otp: String)
        case getProfileStatus(msisdn: String, authToken: String)
    }
    
    enum Output {
        case verifyOtpDidSucceed(response: VerifyOtpResponseModel)
        case verifyOtpDidFail(error: Error)
        case getProfileStatusDidSucceed(response: GetProfileStatusResponse, msisdn: String, authToken: String)
        case getProfileStatusDidFail(error: Error)
    }
}
