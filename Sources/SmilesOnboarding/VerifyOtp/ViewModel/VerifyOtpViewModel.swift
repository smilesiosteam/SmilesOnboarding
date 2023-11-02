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
    var userEmail = ""
    var emailStatePublisher: AnyPublisher<ConfigOTPResponse.State, Never> {
        emailStateSubject.eraseToAnyPublisher()
    }
    var resendCodeStatePublisher: AnyPublisher<ConfigOTPResponse.State, Never> {
        resendCodeStateSubject.eraseToAnyPublisher()
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
        
        securityChecker(mobileNumber: mobileNumber, request: request)
    }
    
    private func getOtpForInternationalNumber(mobileNumber: String, email: String) {
        
        let request = OTPValidtionRequest()
        request.isNewAPICall = "emailNewFlow"
        request.email = AES256Encryption.encrypt(with: email)
        
        let num = String(mobileNumber.dropFirst())
        request.msisdn = num
        SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.msisdn = num
        
        securityChecker(mobileNumber: mobileNumber, request: request)
    }
    
    private func securityChecker(mobileNumber: String, request: OTPValidtionRequest) {
        let enableDeviceSecurityCheck = !isValidEmiratiNumber(phoneNumber: mobileNumber)
        
        let captchaText = ""
        if enableDeviceSecurityCheck && OnBoardingModuleManager.isAppAttestEnabled {
            DeviceAppCheck.shared.getSecurityData { [weak self] dcCheck, attestation, challenge, error  in
                guard let self else {
                    return
                }
                if error != nil {
                    self.output.send(.showLoader(shouldShow: true))
                    let errorModel = ErrorCodeConfiguration()
                    errorModel.errorCode = -1
                    errorModel.errorDescriptionEn = "DeviceJailBreakMsgText".localizedString
                    errorModel.errorDescriptionAr = "DeviceJailBreakMsgText".localizedString
                    if SmilesLanguageManager.shared.currentLanguage == .en {
                        self.emailStateSubject.send(.showAlertWithOkayOnly(message: errorModel.errorDescriptionEn ?? "", title: ""))
                    } else {
                        self.emailStateSubject.send(.showAlertWithOkayOnly(message: errorModel.errorDescriptionAr ?? "", title: ""))
                    }
                } else {
                    request.captcha = captchaText
                    request.deviceCheckToken = dcCheck
                    request.appAttestation = attestation
                    request.challenge = challenge
                    self.getOTPForMobileNumber(with: request)
                }
            }
        } else {
            getOTPForMobileNumber(with: request)
        }
    }
    
    private func getOTPForMobileNumber(with request: OTPValidtionRequest) {
        let service = LoginWithOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .getOtpForMobileNumber
        )
        
        self.output.send(.showLoader(shouldShow: true))
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
        
        let service = LoginWithOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .getOtpForEmail
        )
        
        output.send(.showLoader(shouldShow: true))
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
    
    private func isValidEmiratiNumber(phoneNumber: String) -> Bool {
        let phoneRegex = "^(?:\\+971|971)(?:2|3|4|6|7|9|50|51|52|54|55|56|58)[0-9]{7}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
}
