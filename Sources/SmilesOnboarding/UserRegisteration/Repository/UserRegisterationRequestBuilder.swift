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
    case general(request: Encodable)
    
    var httpMethod: SmilesHTTPMethod {
        return .POST
    }
    
    // compose the NetworkRequest
    func createRequest(baseURL: String, endPoint: UserRegisterationEndPoints) -> NetworkRequest {
        var headers: Headers = [:]

        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        headers["CUSTOM_HEADER"] = "pre_prod"
        
        return NetworkRequest(url: "\(baseURL)\(endPoint.serviceEndPoints)", headers: headers, reqBody: requestBody, httpMethod: httpMethod)
    }
    
    var requestBody: Encodable? {
        switch self {
        case .general(let request):
            return request
        }
    }
}
