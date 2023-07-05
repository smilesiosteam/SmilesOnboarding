//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 04/07/2023.
//

import Foundation
import Combine
import NetworkingLayer

protocol VerifyOtpServiceable {
    func verifyOtp(request: VerifyOtpRequest) -> AnyPublisher<VerifyOtpResponseModel, NetworkError>
    func getProfileStatus(request: GetProfileStatusRequestModel) -> AnyPublisher<GetProfileStatusResponse, NetworkError>
}

// GetCuisinesRepository
class VerifyOtpRepository: VerifyOtpServiceable {

    private var networkRequest: Requestable
    private var baseURL: String
    private var endPoint: SmilesOnboardingEndPoints

  // inject this for testability
    init(networkRequest: Requestable, baseURL: String, endPoint: SmilesOnboardingEndPoints) {
        self.networkRequest = networkRequest
        self.baseURL = baseURL
        self.endPoint = endPoint
    }
    
    func verifyOtp(request: VerifyOtpRequest) -> AnyPublisher<VerifyOtpResponseModel, NetworkingLayer.NetworkError> {
        let endPoint = SmilesOnboardingRequestBuilder.verifyOtp(request: request)
        let request = endPoint.createRequest(
            baseURL: self.baseURL,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
    
    func getProfileStatus(request: GetProfileStatusRequestModel) -> AnyPublisher<GetProfileStatusResponse, NetworkingLayer.NetworkError> {
        let endPoint = SmilesOnboardingRequestBuilder.getProfileStatus(request: request)
        let request = endPoint.createRequest(
            baseURL: self.baseURL,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
}

