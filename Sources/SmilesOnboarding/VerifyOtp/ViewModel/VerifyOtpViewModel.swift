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
import DeviceAppCheck
import SmilesLanguageManager

class VerifyOtpViewModel: NSObject {
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private let configOTPResponse: ConfigOTPResponseType
    private var emailStateSubject = PassthroughSubject<ConfigOTPResponse.State, Never>()
    private var resendCodeStateSubject = PassthroughSubject<ConfigOTPResponse.State, Never>()
    private let securityChecker: SecurityCheckerType
    var userEmail = ""
    var emailStatePublisher: AnyPublisher<ConfigOTPResponse.State, Never> {
        emailStateSubject.eraseToAnyPublisher()
    }
    var resendCodeStatePublisher: AnyPublisher<ConfigOTPResponse.State, Never> {
        resendCodeStateSubject.eraseToAnyPublisher()
    }
    private var baseURL: String
    
    public init(baseURL: String, 
                configOTPResponse: ConfigOTPResponseType = ConfigOTPResponse(),
                securityChecker: SecurityCheckerType = SecurityChecker()) {
        self.baseURL = baseURL
        self.configOTPResponse = configOTPResponse
        self.securityChecker = securityChecker
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
            case .getOTPForLocalNumber(mobileNumber: let mobileNumber):
                self?.getOtpForLocalNumber(mobileNumber: mobileNumber)
                
            case .getOTPForEmail(email: let email, mobileNumber: let mobileNumber):
                self?.getOTPForEmail(email: email, mobileNumber: mobileNumber)
            case .getOTPForInternationalNumber(mobileNumber: let mobileNumber, email: let email):
                self?.getOtpForInternationalNumber(mobileNumber: mobileNumber, email: email)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func verifyOtp(otp: String, loginFlow: LoginFlow) {
        switch loginFlow {
            
        case .localNumber:
            let encryptOTP = AES256Encryption.encrypt(with: otp)
            let request = VerifyOtpRequest(otp: encryptOTP)
            loginWithMobileNumber(request: request)
        case .verifyEmail(email: let email, mobile: let mobile):
            userEmail = email
            loginWithEmail(otp: otp, email: email, mobileNumber: mobile)
        case .verifyMobile(email: let email, mobile: let mobile):
            userEmail = email
            let encryptOTP = AES256Encryption.encrypt(with: otp)
            let request = VerifyOtpRequest(otp: encryptOTP)
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
                let otpState = self.configOTPResponse.handleSuccessResponse(result: response)
                self.emailStateSubject.send(otpState)
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
                //                self?.output.send(.showLoader(shouldShow: false))
                self?.output.send(.verifyOtpDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
    
    func getProfileStatus(msisdn: String, authToken: String) {
        //        self.output.send(.showLoader(shouldShow: true))
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
                //                self?.output.send(.showLoader(shouldShow: false))
                self?.output.send(.getProfileStatusDidSucceed(response: response, msisdn: msisdn, authToken: authToken))
            }
            .store(in: &cancellables)
    }
    
    private func getOtpForLocalNumber(mobileNumber: String) {
        
        let request = OTPValidtionRequest()
        let num = String(mobileNumber.dropFirst())
        request.msisdn = num
        SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.msisdn = num
        
        setSecurityChecker(mobileNumber: mobileNumber, isInternationalNumber: false) { [weak self] model in
            request.captcha = ""
            request.deviceCheckToken = model.deviceCheckToken
            request.appAttestation = model.appAttestation
            request.challenge = model.challenge
            self?.getOTPForMobileNumber(with: request)
        }
    }
    
    private func getOtpForInternationalNumber(mobileNumber: String, email: String) {
        
        let request = OTPValidtionRequest()
        request.isNewAPICall = "emailNewFlow"
        request.email = AES256Encryption.encrypt(with: email)
        
        let num = String(mobileNumber.dropFirst())
        request.msisdn = num
        SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.msisdn = num
        
        setSecurityChecker(mobileNumber: mobileNumber, isInternationalNumber: true) { [weak self] model in
            request.captcha = ""
            request.deviceCheckToken = model.deviceCheckToken
            request.appAttestation = model.appAttestation
            request.challenge = model.challenge
            self?.getOTPForMobileNumber(with: request)
        }
    }
    
    private func setSecurityChecker(mobileNumber: String, isInternationalNumber: Bool , completion: @escaping (SecurityChecker.SecurityModel) -> Void) {
        output.send(.showLoader(shouldShow: true))
        securityChecker.check(mobileNumber: mobileNumber, isInternationalNumber: isInternationalNumber) { [weak self] state in
            guard let self else { return }
            switch state {
                
            case .showError(error: let error):
                self.output.send(.showLoader(shouldShow: false))
                self.emailStateSubject.send(.showAlertWithOkayOnly(message: error, title: ""))
            case .success(model: let model):
                completion(model)
            }
        }
    }
    
    
    
    private func getOTPForMobileNumber(with request: OTPValidtionRequest) {
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
            } receiveValue: { [weak self] response in
                guard let self else {
                    return
                }
                self.output.send(.showLoader(shouldShow: false))
                let otpState = self.configOTPResponse.handleSuccessResponse(result: response)
                self.resendCodeStateSubject.send(otpState)
            }
            .store(in: &cancellables)
    }
    
    private func getOTPForEmail(email: String, mobileNumber: String) {
        let emailEncrypted = AES256Encryption.encrypt(with: email)
        let request = OTPEmailValidationRequest(email: emailEncrypted)
        let msisdn = String(mobileNumber.dropFirst())
        request.msisdn = msisdn
        SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.msisdn = msisdn
        
        setSecurityChecker(mobileNumber: mobileNumber, isInternationalNumber: true) { [weak self] model in
            request.captcha = ""
            request.deviceCheckToken = model.deviceCheckToken
            request.appAttestation = model.appAttestation
            request.challenge = model.challenge
            self?.callOTPForEmail(request: request)
        }
    }
    
    private func callOTPForEmail(request: OTPEmailValidationRequest) {
        let service = LoginWithOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .getOtpForEmail
        )
        
        service.getOTPForEmail(request: request)
            .sink { [weak self] completion  in
                switch completion {
                case .failure(let error):
                    self?.output.send(.showLoader(shouldShow: false))
                    self?.output.send(.getOTPforMobileNumberDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                guard let self else {
                    return
                }
                self.output.send(.showLoader(shouldShow: false))
                let otpState = self.configOTPResponse.handleSuccessResponse(result: response)
                self.resendCodeStateSubject.send(otpState)
            }
            .store(in: &cancellables)
    }
}
