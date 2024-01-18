//
//  LoginTouchIDServiceViewModel.swift
//  House
//
//  Created by Ghullam  Abbas on 18/01/2024.
//  Copyright © 2024 Ahmed samir ali. All rights reserved.
//
import Foundation
import NetworkingLayer
import Combine

public class LoginTouchIDServiceViewModel: NSObject {
    
    // MARK: - INPUT. View event methods
    public  enum Input {
        case loginTouchId(_ token: String?)
    }
    
    enum Output {
        
        case loginTouchIdDidSucceed(response: FullAccessLoginResponse)
        case loginTouchIdDidFail(error: NetworkError)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    let loginTouchIDUseCase: LoginTouchIDUseCaseProtocol
    
      init(loginTouchIDUseCase: LoginTouchIDUseCaseProtocol = LoginTouchIDUseCase()) {
          self.loginTouchIDUseCase = loginTouchIDUseCase
    }
    
}

extension LoginTouchIDServiceViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .loginTouchId( let token):
                self?.loginTouchId(token)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func loginTouchId(_ token: String?) {
        
        loginTouchIDUseCase.loginTouchId(token)
            .sink { [weak self] completion in
                if case.failure(let error) = completion {
                    self?.output.send(.loginTouchIdDidFail(error: error))
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.loginTouchIdDidSucceed(response: response))
            }.store(in: &cancellables)
       
    }
    

}
