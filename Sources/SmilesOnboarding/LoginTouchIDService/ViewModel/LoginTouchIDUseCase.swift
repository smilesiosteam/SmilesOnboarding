//
//  LoginTouchIDUseCase.swift
//  House
//
//  Created by Ghullam  Abbas on 18/01/2024.
//  Copyright © 2024 Ahmed samir ali. All rights reserved.
//

import Foundation
import NetworkingLayer
import Combine
import SmilesBaseMainRequestManager
import SmilesUtilities

protocol LoginTouchIDUseCaseProtocol {
    func loginTouchId(_ token: String?) -> AnyPublisher<FullAccessLoginResponse,NetworkError>
}

final class LoginTouchIDUseCase: LoginTouchIDUseCaseProtocol {
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    
    func loginTouchId(_ token: String?) -> AnyPublisher<FullAccessLoginResponse, NetworkError> {
        
        let request : LoginTouchIdRequest = LoginTouchIdRequest()
        request.touchIdToken = token
        
        let service = LoginTouchIDServiceRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60)
        )
        
        return Future<FullAccessLoginResponse, NetworkError> { [weak self] promise in
            guard let self else {
                return
            }
            service.loginTouchIDServiceRepositoryRequest(request: request)
                .sink { completion in
                    if case .failure(let error) = completion {
                        promise(.failure(error))
                    }
                } receiveValue: { [weak self] response in
                    guard let self else {
                        return
                    }
                    promise(.success(response))
                    
                }
                .store(in: &cancellables)
        }
        .eraseToAnyPublisher()
    }
    
    
}
