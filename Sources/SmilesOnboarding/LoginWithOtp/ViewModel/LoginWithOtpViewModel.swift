//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 25/06/2023.
//

import Foundation
import Combine
import SmilesStoriesManager
import NetworkingLayer

class LoginWithOtpViewModel: NSObject {
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    
    private var baseURL: String
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
}


extension LoginWithOtpViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getCountriesList(let lastModifiedDate, let firstCall):
                self?.getCountries(lastModifiedDate: lastModifiedDate, firstCall: firstCall, baseURL: self?.baseURL ?? "")
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    
    func getCountries(lastModifiedDate: String ,firstCall: Bool, baseURL: String) {
        let request = CountryListRequest()
        request.firstCallFlag = firstCall
        request.lastModifiedDate = lastModifiedDate
        
        let service = GetCountriesRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .getCountries
        )
        
        service.getAllCountriesService(request: request)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchCountriesDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchCountriesDidSucceed(response: response))
            }
        .store(in: &cancellables)
    }
}
