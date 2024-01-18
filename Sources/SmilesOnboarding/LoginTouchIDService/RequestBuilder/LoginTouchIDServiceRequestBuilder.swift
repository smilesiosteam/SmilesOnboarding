//
//  LoginTouchIDServiceRequestBuilder.swift
//  House
//
//  Created by Ghullam  Abbas on 18/01/2024.
//  Copyright © 2024 Ahmed samir ali. All rights reserved.
//
import Foundation
import NetworkingLayer
import SmilesUtilities
import SmilesBaseMainRequestManager

enum LoginTouchIDServiceRequestBuilder {
    
    case loginTouchIDServiceRequestBuilder(request: SmilesBaseMainRequest)
    
    var requestTimeOut: Int {
        return 20
    }
    
    var httpMethod: SmilesHTTPMethod {
        switch self {
        case .loginTouchIDServiceRequestBuilder:
            return .POST
        }
    }
    
    // compose the NetworkRequest
    func createRequest(endPoint: LoginTouchIDServiceEndPoints) -> NetworkRequest {
        var headers: [String: String] = [:]

        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        headers["CUSTOM_HEADER"] = "pre_prod"
        
        return NetworkRequest(url: getURL(for: endPoint), headers: headers, reqBody: requestBody, httpMethod: httpMethod)
    }
    
    var requestBody: Encodable? {
        switch self {
        case .loginTouchIDServiceRequestBuilder(let request):
            return request
        }
        
    }
    
    func getURL(for endPoint: LoginTouchIDServiceEndPoints) -> String {
        return AppCommonMethods.serviceBaseUrl + endPoint.serviceEndPoints
    }
}

