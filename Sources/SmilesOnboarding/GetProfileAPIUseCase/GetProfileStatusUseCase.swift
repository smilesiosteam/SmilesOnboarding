//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 17/01/2024.
//

import Foundation
import NetworkingLayer
import Combine
import SmilesBaseMainRequestManager
import SmilesUtilities

protocol GetProfilseStatusUseCaseProtocol {
    func getProfileStatus(msisdn: String , authToken: String) -> AnyPublisher<GetProfileStatusResponse,NetworkError>
}

final class GetProfileStatusUseCase: GetProfilseStatusUseCaseProtocol {
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    
    func getProfileStatus(msisdn: String, authToken: String) -> AnyPublisher<GetProfileStatusResponse, NetworkError> {
        
        SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.authToken = authToken
        SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.msisdn = msisdn
        
        let request =  SmilesBaseMainRequest()
        
        let service = GetProfileStatusRequestRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60)
        )
        
        return Future<GetProfileStatusResponse, NetworkError> { [weak self] promise in
            guard let self else {
                return
            }
            service.getProfileStatusRequestRepositoryRequest(request: request)
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
