//
//  LoginTouchIDServiceRepository.swift
//  House
//
//  Created by Ghullam  Abbas on 18/01/2024.
//  Copyright © 2024 Ahmed samir ali. All rights reserved.
//
import Foundation
import Combine
import NetworkingLayer
import SmilesOffers
import SmilesBaseMainRequestManager

protocol LoginTouchIDServiceRepositoryServiceable {
    func loginTouchIDServiceRepositoryRequest(request: SmilesBaseMainRequest) -> AnyPublisher<FullAccessLoginResponse, NetworkError>
}

class LoginTouchIDServiceRepository: LoginTouchIDServiceRepositoryServiceable {
    
    private var networkRequest: Requestable
    
  // inject this for testability
    init(networkRequest: Requestable) {
        self.networkRequest = networkRequest
    }
  
    func loginTouchIDServiceRepositoryRequest(request: SmilesBaseMainRequest) -> AnyPublisher<FullAccessLoginResponse, NetworkError> {
        let endPoint = LoginTouchIDServiceRequestBuilder.loginTouchIDServiceRequestBuilder(request: request)
        let request = endPoint.createRequest(endPoint: .loginTouchID)
        return self.networkRequest.request(request)
    }
    
}
