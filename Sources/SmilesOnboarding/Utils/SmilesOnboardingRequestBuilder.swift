//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 26/06/2023.
//

import Foundation
import NetworkingLayer

fileprivate typealias Headers = [String: String]
// if you wish you can have multiple services like this in a project
enum SmilesOnboardingRequestBuilder {
    
    // organise all the end points here for clarity
    case getCountries(request: CountryListRequest)
    
    // gave a default timeout but can be different for each.
    var requestTimeOut: Int {
        return 20
    }
    
    //specify the type of HTTP request
    var httpMethod: SmilesHTTPMethod {
        switch self {
        case .getCountries:
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
        }
    }
    
    // compose urls for each request
    func getURL(from baseURL: String, for endPoint: SmilesOnboardingEndPoints) -> String {
        
        let endPoint = endPoint.serviceEndPoints
        switch self {
        case .getCountries:
            return "\(baseURL)\(endPoint)"
        }
        
    }
}
