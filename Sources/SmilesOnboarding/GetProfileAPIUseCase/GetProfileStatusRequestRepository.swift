//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 17/01/2024.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesOffers
import SmilesBaseMainRequestManager

protocol GetProfileStatusRequestRepositoryServiceable {
    func getProfileStatusRequestRepositoryRequest(request: SmilesBaseMainRequest) -> AnyPublisher<GetProfileStatusResponse, NetworkError>
}

class GetProfileStatusRequestRepository: GetProfileStatusRequestRepositoryServiceable {
    
    private var networkRequest: Requestable
    
  // inject this for testability
    init(networkRequest: Requestable) {
        self.networkRequest = networkRequest
    }

    func getProfileStatusRequestRepositoryRequest(request: SmilesBaseMainRequest) -> AnyPublisher<GetProfileStatusResponse, NetworkError> {
        let endPoint = GetProfileStatusRequestRequestBuilder.getProfileStatusRequestRequestBuilder(request: request)
        let request = endPoint.createRequest(endPoint: .getProfileStatus)
        return self.networkRequest.request(request)
    }
    
}
