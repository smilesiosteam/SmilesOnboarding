//
//  UserRegisterationRequestBuilder.swift
//  
//
//  Created by Shmeel Ahmed on 26/06/2023.
//

import Foundation
import NetworkingLayer

fileprivate typealias Headers = [String: String]

enum UserRegisterationRequestBuilder {
    case fetchInfo(request: FetchInfoRequest)
    case registerUser(request: RegisterUserRequest)
    
    var requestTimeOut: Int {
        return 20
    }
    
    
    var httpMethod: SmilesHTTPMethod {
        switch self {
        case .fetchInfo:
            return .POST
        case .registerUser:
            return .POST
        }
    }
    
    // compose the NetworkRequest
    func createRequest(baseURL: String, endPoint: UserRegisterationEndPoints) -> NetworkRequest {
        var headers: Headers = [:]

        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        headers["CUSTOM_HEADER"] = "pre_prod"
        
        return NetworkRequest(url: getURL(from: baseURL, for: endPoint), headers: headers, reqBody: requestBody, httpMethod: httpMethod)
    }
    
    var requestBody: Encodable? {
        switch self {
        case .fetchInfo(let request):
            return request
        case .registerUser(let request):
            return request
        }
    }
    
    func getURL(from baseURL: String, for endPoint: UserRegisterationEndPoints) -> String {
        
        let endPoint = endPoint.serviceEndPoints
        switch self {
        case .fetchInfo,.registerUser:
            return "\(baseURL)\(endPoint)"
        }
    }
}
