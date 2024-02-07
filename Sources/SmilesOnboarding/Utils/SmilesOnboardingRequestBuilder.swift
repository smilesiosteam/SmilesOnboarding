//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 26/06/2023.
//

import Foundation
import NetworkingLayer
import SmilesBaseMainRequestManager

fileprivate typealias Headers = [String: String]
// if you wish you can have multiple services like this in a project
enum SmilesOnboardingRequestBuilder {
    
    // organise all the end points here for clarity
    case getCountries(request: CountryListRequest)
    case getOTPforMobileNumber(request: OTPValidtionRequest)
    case verifyOtp(request: VerifyOtpRequest)
    case getProfileStatus(request: GetProfileStatusRequestModel)
    case loginAsGuest(request: GuestUserRequestModel)
    case authenticateTouchId(request: EnableTouchIdRequestModel)
    case getOTPForEmail(request: OTPEmailValidationRequest)
    case verifyOTPForEmail(request: VerifyEmailOTPRequest)
    case emailVerificationStatus(request: SmilesBaseMainRequest)
    // gave a default timeout but can be different for each.
    var requestTimeOut: Int {
        return 20
    }
    
    //specify the type of HTTP request
    var httpMethod: SmilesHTTPMethod {
        switch self {
        case .getCountries:
            return .POST
        case .getOTPforMobileNumber:
            return .POST
        case .verifyOtp:
            return .POST
        case .getProfileStatus:
            return .POST
        case .loginAsGuest:
            return .POST
        case .authenticateTouchId:
            return .POST
        case .getOTPForEmail:
            return .POST
        case .verifyOTPForEmail:
            return .POST
        case .emailVerificationStatus:
            return .POST
        }
    }
        
    // compose the NetworkRequest
    func createRequest(baseURL: String, endPoint: SmilesOnboardingEndPoints) -> NetworkRequest {
        var headers: Headers = [:]
        
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        headers["CUSTOM_HEADER"] = "pre_prod"
        
        return NetworkRequest(url: getURL(from: baseURL, for: endPoint), headers: headers, reqBody: requestBody, httpMethod: httpMethod)
    }
    
    // encodable request body for POST
    var requestBody: Encodable? {
        switch self {
        case .getCountries(let request):
            return request
        case .getOTPforMobileNumber(let request):
            return request
        case .verifyOtp(let request):
            return request
        case .getProfileStatus(let request):
            return request
        case .loginAsGuest(let request):
            return request
        case .authenticateTouchId(let request):
            return request
        case .getOTPForEmail(request: let request):
            return request
        case .verifyOTPForEmail(request: let request):
            return request
        case .emailVerificationStatus(request: let request):
            return request
        }
    }
    
    // compose urls for each request
    func getURL(from baseURL: String, for endPoint: SmilesOnboardingEndPoints) -> String {
        
        let endPoint = endPoint.serviceEndPoints
        switch self {
        case .getCountries:
            return "\(baseURL)\(endPoint)"
        case .getOTPforMobileNumber:
            return "\(baseURL)\(endPoint)"
        case .verifyOtp:
            return "\(baseURL)\(endPoint)"
        case .getProfileStatus:
            return "\(baseURL)\(endPoint)"
        case .loginAsGuest:
            return "\(baseURL)\(endPoint)"
        case .authenticateTouchId:
            return "\(baseURL)\(endPoint)"
        case .getOTPForEmail, .verifyOTPForEmail:
            return "\(baseURL)\(endPoint)"
        case .emailVerificationStatus:
            return "\(baseURL)\(endPoint)"
        }
        
    }
}
