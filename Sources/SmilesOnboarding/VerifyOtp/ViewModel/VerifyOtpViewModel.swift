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
    private let configOTPResponse: ConfigOTPResponseType
    private var emailStateSubject = PassthroughSubject<ConfigOTPResponse.State, Never>()
    var userEmail = ""
    var emailStatePublisher: AnyPublisher<ConfigOTPResponse.State, Never> {
        emailStateSubject.eraseToAnyPublisher()
    }
    private var baseURL: String
    
    public init(baseURL: String, configOTPResponse: ConfigOTPResponseType = ConfigOTPResponse()) {
        self.baseURL = baseURL
        self.configOTPResponse = configOTPResponse
    }
}

extension VerifyOtpViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .verifyOtp(otp: let otp, type: let type):
                self?.verifyOtp(otp: otp, loginFlow: type)
            case .getProfileStatus(msisdn: let msisdn, authToken: let authToken):
                self?.getProfileStatus(msisdn: msisdn, authToken: authToken)
            case .getOTPforMobileNumber(mobileNumber: let mobileNumber):
                self?.getOtpForMobileNumber(mobileNumber: mobileNumber, captchaText: "", deviceCheckToken: "", appAttestation: "", challenge: "")
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func verifyOtp(otp: String, loginFlow: LoginFlow) {
        switch loginFlow {
            
        case .internationalNumber:
            let request = VerifyOtpRequest(otp: otp)
            request.otpType = loginFlow.otpType
            loginWithMobileNumber(request: request)
        case .email(email: let email, mobile: let mobile):
            userEmail = email
            loginWithEmail(otp: otp, email: email, mobileNumber: mobile)
        case .verifyEmail(email: let email, mobile: let mobile):
            let request = VerifyOtpRequest(otp: otp)
            request.otpType = loginFlow.otpType
            request.email = AES256Encryption.encrypt(with: email)
            request.msisdn = mobile
            loginWithMobileNumber(request: request)
        }
    }
    
    private func loginWithEmail(otp: String, email: String, mobileNumber: String) {
        let emailEncrypted = AES256Encryption.encrypt(with: email)
        let otpEncrypted = AES256Encryption.encrypt(with: otp)
        let request = VerifyEmailOTPRequest(otp: otpEncrypted, email: emailEncrypted)
        output.send(.showLoader(shouldShow: true))
        let service = VerifyOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .verifyOtpForEmail
        )
        
        request.msisdn = String(mobileNumber.dropFirst())
        service.verifyOTPForEmail(request: request)
            .sink { [weak self] completion in
                self?.output.send(.showLoader(shouldShow: false))
                if case .failure(let error)  = completion {
                    self?.output.send(.verifyOtpDidFail(error: error))
                }
                    
            } receiveValue: { [weak self] response in
                guard let self else {
                    return
                }
                self.configOTPResponse.handleSuccessResponse(result: response)
                    .subscribe(self.emailStateSubject)
                    .store(in: &cancellables)                
            }.store(in: &cancellables)

    }
    
    private func loginWithMobileNumber(request: VerifyOtpRequest) {
        output.send(.showLoader(shouldShow: true))
        let service = VerifyOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .verifyOtp
        )
        
        service.verifyOtp(request: request)
            .sink {[weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.output.send(.showLoader(shouldShow: false))
                    self?.output.send(.verifyOtpDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: {[weak self] response in
                self?.output.send(.showLoader(shouldShow: false))
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
                switch completion {
                case .failure(let error):
                    self?.output.send(.showLoader(shouldShow: false))
                    self?.output.send(.getProfileStatusDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response  in
                self?.output.send(.showLoader(shouldShow: false))
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
                switch completion {
                case .failure(let error):
                    self?.output.send(.showLoader(shouldShow: false))
                    self?.output.send(.getOTPforMobileNumberDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: {   [weak self] response in
                self?.output.send(.showLoader(shouldShow: false))
                self?.output.send(.getOTPforMobileNumberDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
}
