//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 04/07/2023.
//

import Foundation
import NetworkingLayer
extension VerifyOtpViewModel {
    enum Input {
        case verifyOtp(otp: String, type: LoginFlow)
        case getProfileStatus(msisdn: String, authToken: String)
        case getOTPforMobileNumber(mobileNumber: String)
        case getOTPForEmail(email: String, mobileNumber: String)
    }
    
    enum Output {
        case verifyOtpDidSucceed(response: VerifyOtpResponseModel)
        case verifyOtpDidFail(error: NetworkError)
        case getProfileStatusDidSucceed(response: GetProfileStatusResponse, msisdn: String, authToken: String)
        case getProfileStatusDidFail(error: NetworkError)
        case showLoader(shouldShow: Bool)
        case getOTPforMobileNumberDidSucceed(response: CreateOtpResponse)
        case getOTPforMobileNumberDidFail(error: NetworkError)
    }
}
