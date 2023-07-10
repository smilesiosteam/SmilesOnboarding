//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 09/07/2023.
//

import Foundation
import Combine
import NetworkingLayer

protocol EnabletouchIdServiceable {
    func authenticateTouchId(request: EnableTouchIdRequestModel) -> AnyPublisher<EnableTouchIdResponseModel, NetworkError>
}

// GetCuisinesRepository
class EnabletouchIdRepository: EnabletouchIdServiceable {

    private var networkRequest: Requestable
    private var baseURL: String
    private var endPoint: SmilesOnboardingEndPoints

  // inject this for testability
    init(networkRequest: Requestable, baseURL: String, endPoint: SmilesOnboardingEndPoints) {
        self.networkRequest = networkRequest
        self.baseURL = baseURL
        self.endPoint = endPoint
    }
    
    func authenticateTouchId(request: EnableTouchIdRequestModel) -> AnyPublisher<EnableTouchIdResponseModel, NetworkingLayer.NetworkError> {
        let endPoint = SmilesOnboardingRequestBuilder.authenticateTouchId(request: request)
        let request = endPoint.createRequest(
            baseURL: self.baseURL,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
}

