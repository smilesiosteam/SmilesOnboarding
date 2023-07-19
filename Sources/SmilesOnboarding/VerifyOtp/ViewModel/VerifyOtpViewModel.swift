//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 04/07/2023.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesBaseMainRequestManager

class VerifyOtpViewModel: NSObject {
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    
    private var baseURL: String
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
}

extension VerifyOtpViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .verifyOtp(otp: let otp):
                self?.verifyOtp(otp: otp)
            case .getProfileStatus(msisdn: let msisdn, authToken: let authToken):
                self?.getProfileStatus(msisdn: msisdn, authToken: authToken)
            case .getOTPforMobileNumber(mobileNumber: let mobileNumber):
                self?.getOtpForMobileNumber(mobileNumber: mobileNumber, captchaText: "", deviceCheckToken: "", appAttestation: "", challenge: "")
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func verifyOtp(otp: String) {
        let request = VerifyOtpRequest(otp: otp)
        self.output.send(.showLoader(shouldShow: true))
        let service = VerifyOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .verifyOtp
        )
        
        service.verifyOtp(request: request)
            .sink {[weak self] completion in
                self?.output.send(.showLoader(shouldShow: false))
                switch completion {
                case .failure(let error):
                    self?.output.send(.verifyOtpDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: {[weak self] response in
                self?.output.send(.verifyOtpDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
    
    func getProfileStatus(msisdn: String, authToken: String) {
        self.output.send(.showLoader(shouldShow: true))
        let request = GetProfileStatusRequestModel()
        SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.msisdn = msisdn
        SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.authToken = authToken
        
        let service = VerifyOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .getProfileStatus
        )
        
        service.getProfileStatus(request: request)
            .sink { [weak self] completion  in
                self?.output.send(.showLoader(shouldShow: false))
                switch completion {
                case .failure(let error):
                    self?.output.send(.getProfileStatusDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response  in
                self?.output.send(.getProfileStatusDidSucceed(response: response, msisdn: msisdn, authToken: authToken))
            }
            .store(in: &cancellables)
    }
    
    func getOtpForMobileNumber(mobileNumber: String,  captchaText: String, deviceCheckToken:String?, appAttestation:String?, challenge:String?) {
        self.output.send(.showLoader(shouldShow: true))
        let request = OTPValidtionRequest(captcha: captchaText, deviceCheckToken: deviceCheckToken, appAttestation: appAttestation, challenge: challenge)

        let num = String(mobileNumber.dropFirst())
        request.msisdn = num
        SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.msisdn = num
        
        let service = LoginWithOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .getOtpForMobileNumber
        )
        
        service.getOTPforMobileNumber(request: request)
            .sink { [weak self] completion  in
                debugPrint(completion)
                self?.output.send(.showLoader(shouldShow: false))
                switch completion {
                case .failure(let error):
                    self?.output.send(.getOTPforMobileNumberDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: {   [weak self] response in
                self?.output.send(.getOTPforMobileNumberDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
}
