//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 17/01/2024.
//

import Foundation
import NetworkingLayer
import SmilesUtilities
import SmilesBaseMainRequestManager

enum GetProfileStatusRequestRequestBuilder {
    
    case getProfileStatusRequestRequestBuilder(request: SmilesBaseMainRequest)
    
    var requestTimeOut: Int {
        return 20
    }
    
    var httpMethod: SmilesHTTPMethod {
        switch self {
        case .getProfileStatusRequestRequestBuilder:
            return .POST
        }
    }
    
    // compose the NetworkRequest
    func createRequest(endPoint: GetProfileStatusRequestEndPoints) -> NetworkRequest {
        var headers: [String: String] = [:]

        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        headers["CUSTOM_HEADER"] = "pre_prod"
        
        return NetworkRequest(url: getURL(for: endPoint), headers: headers, reqBody: requestBody, httpMethod: httpMethod)
    }
    
    var requestBody: Encodable? {
        switch self {
        case .getProfileStatusRequestRequestBuilder(let request):
            return request
        }
        
    }
    
    func getURL(for endPoint: GetProfileStatusRequestEndPoints) -> String {
        return AppCommonMethods.serviceBaseUrl + endPoint.serviceEndPoints
    }
}

