//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 25/06/2023.
//

import Foundation
import NetworkingLayer

extension LoginWithOtpViewModel {
    
    enum Input {
        case loginTouchId(_ token: String?)
        case authenticateTouchId(token: String, isEnabled: Bool)
        case getProfileStatus(msisdn: String , authToken: String)
        case getCountriesList(lastModifiedDate: String ,firstCall: Bool)
        case getOTPforMobileNumber(mobileNumber: String, enableDeviceSecurityCheck:Bool)
        case loginAsGuestUser
    }
    
    enum Output {
        
        case loginTouchIdDidSucceed(response: FullAccessLoginResponse)
        case loginTouchIdDidFail(error: NetworkError)
        case authenticateTouchIdDidSucceed(response: EnableTouchIdResponseModel)
        case authenticateTouchIdDidfail(error: NetworkError)
        case getProfileStatusDidSucceed(response: GetProfileStatusResponse)
        case getProfileStatusDidFail(error: NetworkError)
        case fetchCountriesDidSucceed(response: CountryListResponse)
        case fetchCountriesDidFail(error: NetworkError)
        case getOTPforMobileNumberDidSucceed(response: CreateOtpResponse)
        case getOTPforMobileNumberDidFail(error: NetworkError)
        case showLoader(shouldShow: Bool)
        case loginAsGuestDidSucceed(response: GuestUserResponseModel)
        case loginAsGuestDidFail(error: NetworkError)
        case errorOutPut(error: String)
        case navigateToEmailVerification(message: String)
        case showLimitExceedPopup(title: String, subTitle: String)
    }
}
