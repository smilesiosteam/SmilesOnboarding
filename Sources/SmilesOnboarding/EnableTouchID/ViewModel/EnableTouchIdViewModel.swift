//
//  EnableTouchIdViewModel.swift
//  House
//
//  Created by Shahroze Zaheer on 07/07/2023.
//  Copyright (c) 2023 All rights reserved.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesBaseMainRequestManager

class EnableTouchIdViewModel {
    
    // MARK: -- Variables
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    private var baseURL: String
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
}

// MARK: - INPUT. View event methods
extension EnableTouchIdViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .authenticateTouchId(let token, let isEnabled):
                self?.authenticateTouchId(token: token, isEnabled: isEnabled)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func authenticateTouchId(token: String, isEnabled: Bool) {
        let request = EnableTouchIdRequestModel(enabled: isEnabled, touchIdToken: token)
        
        let service = EnabletouchIdRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .authenticateTouchId
        )
        
        service.authenticateTouchId(request: request)
            .sink { [weak self] completion  in
                switch completion {
                case .failure(let error):
                    self?.output.send(.authenticateTouchIdDidfail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response  in
                self?.output.send(.authenticateTouchIdDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
}
