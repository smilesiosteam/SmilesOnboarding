//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 25/06/2023.
//

import Foundation
import Combine
import NetworkingLayer

protocol LoginWithOtpServiceable {
    func getAllCountriesService(request: CountryListRequest) -> AnyPublisher<CountryListResponse, NetworkError>
}

// GetCuisinesRepository
class GetCountriesRepository: LoginWithOtpServiceable {
    
    private var networkRequest: Requestable
    private var baseURL: String
    private var endPoint: SmilesOnboardingEndPoints

  // inject this for testability
    init(networkRequest: Requestable, baseURL: String, endPoint: SmilesOnboardingEndPoints) {
        self.networkRequest = networkRequest
        self.baseURL = baseURL
        self.endPoint = endPoint
    }
  
    func getAllCountriesService(request: CountryListRequest) -> AnyPublisher<CountryListResponse, NetworkError> {
        let endPoint = SmilesOnboardingRequestBuilder.getCountries(request: request)
        let request = endPoint.createRequest(
            baseURL: self.baseURL,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
}

