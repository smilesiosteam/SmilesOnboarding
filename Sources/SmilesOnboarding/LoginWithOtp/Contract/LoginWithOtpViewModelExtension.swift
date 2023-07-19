//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 25/06/2023.
//

import Foundation

extension LoginWithOtpViewModel {
    enum Input {
        case getCountriesList(lastModifiedDate: String ,firstCall: Bool)
        case generateCaptcha(mobileNumber: String)
        case getOTPforMobileNumber(mobileNumber: String, enableDeviceSecurityCheck:Bool)
        case loginAsGuestUser
    }
    
    enum Output {
        case fetchCountriesDidSucceed(response: CountryListResponse)
        case fetchCountriesDidFail(error: Error)
        case generateCaptchaDidSucced(response: CaptchaResponseModel?)
        case generateCaptchaDidFail(error: Error)
        case getOTPforMobileNumberDidSucceed(response: CreateOtpResponse)
        case getOTPforMobileNumberDidFail(error: Error)
        case showLoader(shouldShow: Bool)
        case loginAsGuestDidSucceed(response: GuestUserResponseModel)
        case loginAsGuestDidFail(error: Error)
        case errorOutPut(error: String)
    }
}
