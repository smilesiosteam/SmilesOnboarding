//
//  UserRegisterationViewModel.swift
//  
//
//  Created by Shmeel Ahmed on 26/06/2023.
//

import Combine
import NetworkingLayer
import UIKit
import SmilesUtilities
import SmilesLanguageManager
import SmilesBaseMainRequestManager

public class UserRegisterationViewModel:NSObject {
    
    // MARK: - INPUT. View event methods
    public enum Input {
        case fetchInfo(type:InfoType)
        case registerUser(request:RegisterUserRequest)
        case verifyUserDetails(request:RegisterUserRequest)
    }
    
    public enum Output {
        case fetchInfoDidSucceed(response: InfoResponse)
        case registerUserDidSucceed(response: RegisterUserResponse)
        case verifyUserDetailsDidSucceed(response: VerifyUserDetailsResponse)
        case fetchDidFail(error: NetworkError)
        case registerUserDidFail(error: NetworkError)
        case verifyingDetailsDidFail(error: NetworkError)
        case showHideLoader(shouldShow: Bool)
    }
    
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    public var infoResponse: InfoResponse?
    private var baseURL: String
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
    
}

// MARK: - INPUT. View event methods
public extension UserRegisterationViewModel {
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            guard let self else { return }
            self.output.send(.showHideLoader(shouldShow: true))
            switch event {
            case .fetchInfo(let type):
                self.fetchInfo(type: type, baseURL: self.baseURL) { resp in
                    self.infoResponse = resp
                    self.output.send(.fetchInfoDidSucceed(response: resp))
                    self.output.send(.showHideLoader(shouldShow: false))
                } failure: { error in
                    self.output.send(.fetchDidFail(error: error))
                    self.output.send(.showHideLoader(shouldShow: false))
                }

            case .registerUser(request: let request):
                self.registerUser(request: request, baseURL: self.baseURL) { response in
                    self.handleResponse(response: response)
                    self.output.send(.showHideLoader(shouldShow: false))
                } failure: { error in
                    self.output.send(.registerUserDidFail(error: error))
                    self.output.send(.showHideLoader(shouldShow: false))
                }
            case .verifyUserDetails(request: let request):
                self.verifyUserDetails(request: request, baseURL: self.baseURL) { response in
                    self.output.send(.verifyUserDetailsDidSucceed(response: response))
                    self.output.send(.showHideLoader(shouldShow: false))
                } failure: { error in
                    self.output.send(.registerUserDidFail(error: error))
                    self.output.send(.showHideLoader(shouldShow: false))
                }
            }
        }.store(in: &cancellables)
        
        return output.eraseToAnyPublisher()
    }
    
    func handleResponse(response:RegisterUserResponse){
        if ErrorDisplayMsgs.isResponseFaild(response: response){
            // in case of error, we will remove enrollment response object
            RegisterUserResponse.removeEnrollReponse()
            self.output.send(.registerUserDidFail(error:NetworkError.apiError(code: -1, error: ErrorDisplayMsgs.returnServiceFailureMessage(response: response))))
            
        }else {
            UserDefaults.standard.set(true, forKey: .showOnboardScratchCard)
            
            RegisterUserResponse.saveRegisterUserResponse(enrollData: response)
            

            if let additionalInfo = response.additionalInfo {
                for  info : BaseMainResponseAdditionalInfo in additionalInfo {
                    if let type = response.type {
                        if type == 3 {
                            if info.name?.lowercased() == "redirectionURL".lowercased() {
                                if let info = info.value{
                                    UserDefaults.standard.set(info, forKey: "redirectionURL")
                                }
                            }
                            
                            if info.name?.lowercased() == "categoryId".lowercased() {
                                if let info = info.name{
                                    UserDefaults.standard.set(info, forKey: "categoryId")
                                }
                            }
//                                break
                        }
                        else if type == 1{
                            if info.name?.lowercased() == "duration".lowercased(){
                                if let info = info.name{
                                    UserDefaults.standard.set(info, forKey: "duration")
                                }
                            }
                            if info.name?.lowercased() == "promoCode".lowercased(){
                                if let info = info.name{
                                    UserDefaults.standard.set(info, forKey: "promoCode")
                                }
                            }
//                                break
                        }
                        else if type == 2{
                            break
                        }
                    }
                    
                }
                
            }
            self.output.send(.registerUserDidSucceed(response: response))
        }
        
    }
    func fetchInfo(type: InfoType, baseURL: String, success: @escaping (InfoResponse) -> Void, failure: @escaping (NetworkError) -> Void) {
        let request = FetchInfoRequest(infoType: type.rawValue)
        
        let service = UserRegisterationRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .fetchInfo
        )
        
        service.fetchInfo(request: request)
            .sink { completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    failure(error)
                default: break
                }
            } receiveValue: { response in
                success(response)
            }
            .store(in: &cancellables)
    }
    
    func registerUser(request: RegisterUserRequest, baseURL: String, success: @escaping (RegisterUserResponse) -> Void, failure: @escaping (NetworkError) -> Void) {
        let service = UserRegisterationRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .register
        )
        
        service.registerUser(request: request)
            .sink { completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    failure(error)
                default: break
                }
            } receiveValue: { response in
                success(response)
            }
            .store(in: &cancellables)
    }
    
    func verifyUserDetails(request: RegisterUserRequest, baseURL: String, success: @escaping (VerifyUserDetailsResponse) -> Void, failure: @escaping (NetworkError) -> Void) {
        let service = UserRegisterationRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .verifyDetails
        )
        
        service.verifyUserDetails(request: request)
            .sink { completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    failure(error)
                default: break
                }
            } receiveValue: { response in
                success(response)
            }
            .store(in: &cancellables)
    }
    
}
