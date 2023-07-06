//
//  SmilesGetStoriesRepository.swift
//  
//
//  Created by Shmeel Ahmed on 26/06/2023.
//


import Foundation
import Combine
import NetworkingLayer

protocol UserRegisterationServiceable {
    func fetchInfo(request: FetchInfoRequest) -> AnyPublisher<InfoResponse, NetworkError>
    func registerUser(request: RegisterUserRequest) -> AnyPublisher<RegisterUserResponse, NetworkError>
    func verifyUserDetails(request: RegisterUserRequest) -> AnyPublisher<VerifyUserDetailsResponse, NetworkError>
}

class UserRegisterationRepository: UserRegisterationServiceable {
    
    private var networkRequest: Requestable
    private var baseURL: String
    private var endPoint: UserRegisterationEndPoints

  // inject this for testability
    init(networkRequest: Requestable, baseURL: String, endPoint: UserRegisterationEndPoints) {
        self.networkRequest = networkRequest
        self.baseURL = baseURL
        self.endPoint = endPoint
    }
    
    func fetchInfo(request: FetchInfoRequest) -> AnyPublisher<InfoResponse, NetworkError> {
        let endPoint = UserRegisterationRequestBuilder.general(request: request)
        let request = endPoint.createRequest(
            baseURL: baseURL,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
    func registerUser(request: RegisterUserRequest) -> AnyPublisher<RegisterUserResponse, NetworkError> {
        let endPoint = UserRegisterationRequestBuilder.general(request: request)
        let request = endPoint.createRequest(
            baseURL: baseURL,
            endPoint: self.endPoint
        )
        
        return self.networkRequest.request(request)
    }
    func verifyUserDetails(request: RegisterUserRequest) -> AnyPublisher<VerifyUserDetailsResponse, NetworkingLayer.NetworkError> {
        let endPoint = UserRegisterationRequestBuilder.general(request: request)
        let request = endPoint.createRequest(
            baseURL: baseURL,
            endPoint: self.endPoint
        )
        return self.networkRequest.request(request)
    }
}

public enum UserRegisterationEndPoints: String, CaseIterable {
    case fetchInfo,register,verifyDetails
}

extension UserRegisterationEndPoints {
    var serviceEndPoints: String {
        switch self {
        case .fetchInfo:
            return "config/info-items"
        case .register:
            return "login/enroll"
        case .verifyDetails:
            return "login/verify-login-details"
        }
    }
}
