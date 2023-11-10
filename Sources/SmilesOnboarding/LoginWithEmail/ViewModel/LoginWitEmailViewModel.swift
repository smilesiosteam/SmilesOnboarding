//
//  File.swift
//  
//
//  Created by Ahmed Naguib on 16/10/2023.
//

import Foundation
import SmilesBaseMainRequestManager
import NetworkingLayer
import Combine

extension LoginWitEmailViewModel {
    enum State {
        case isValuedEmail(Bool)
        case isEmailTextNotEmpty(Bool)
        case showLoader(Bool)
        case showAlertWithOkayOnly(message: String, title: String)
    }
}

final class LoginWitEmailViewModel {
    
    // MARK: - Input
    var emailTextSubject = CurrentValueSubject<String, Never>("")
    
    // MARK: - OutPut
    @Published private(set) var state: State = .isValuedEmail(false)
    var successState = PassthroughSubject<ConfigOTPResponse.State, Never>()
    
    // MARK: - Properties
    private var cancallbles = Set<AnyCancellable>()
    let mobileNumber: String
    let baseURL: String
    private let configOTPResponse: ConfigOTPResponseType
    private let securityChecker: SecurityCheckerType
    
    // MARK: - Init
    init(mobileNumber: String, baseURL: String, 
         configOTPResponse: ConfigOTPResponseType = ConfigOTPResponse(),
         securityChecker: SecurityCheckerType = SecurityChecker()) {
        self.mobileNumber = mobileNumber
        self.baseURL = baseURL
        self.configOTPResponse = configOTPResponse
        self.securityChecker = securityChecker
        checkForValidEmail()
        checkIsEmailTextFiledIsNotEmpty()
    }
    
    private func checkForValidEmail() {
        emailTextSubject.map { [weak self] value in
            guard let self else {
                return false
            }
            return self.isValidEmail(value)
        }
        .sink { [weak self] value in
            guard let self else { return }
            self.state = .isValuedEmail(value)
        }
        .store(in: &cancallbles)
        
    }
    
    private func checkIsEmailTextFiledIsNotEmpty() {
        emailTextSubject.map { value in
            return !value.isEmpty
        }
        .sink { [weak self] value in
            guard let self else { return }
            self.state = .isEmailTextNotEmpty(value)
        }
        .store(in: &cancallbles)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

extension LoginWitEmailViewModel {
    private func setSecurityChecker(mobileNumber: String, completion: @escaping (SecurityChecker.SecurityModel) -> Void) {
        state = .showLoader(true)
        securityChecker.check(mobileNumber: mobileNumber, isInternationalNumber: true) { [weak self] state in
            guard let self else { return }
            switch state {
                
            case .showError(error: let error):
                self.state = .showLoader(false)
                self.state = .showAlertWithOkayOnly(message: error, title: OnboardingLocalizationKeys.noTitleError.text)
            case .success(model: let model):
                completion(model)
            }
        }
    }
    
    func sendCode() {
        let emailEncrypted = AES256Encryption.encrypt(with: emailTextSubject.value)
        let request = OTPEmailValidationRequest(email: emailEncrypted)
        let msisdn = String(mobileNumber.dropFirst())
        request.msisdn = msisdn
        SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.msisdn = msisdn
        
       
        setSecurityChecker(mobileNumber: mobileNumber) { [weak self] model in
            request.captcha = ""
            request.deviceCheckToken = model.deviceCheckToken
            request.appAttestation = model.appAttestation
            request.challenge = model.challenge
            self?.callSendCodeAPI(request: request)
        }
    }
    
    private func callSendCodeAPI(request: OTPEmailValidationRequest) {
        let service = LoginWithOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .getOtpForEmail
        )
        
        service.getOTPForEmail(request: request)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.state = .showAlertWithOkayOnly(message: error.localizedDescription, title: OnboardingLocalizationKeys.noTitleError.text)
                }
                self?.state = .showLoader(false)
            } receiveValue: { [weak self] response in
                guard let self  else {
                    return
                }
               let otpState = self.configOTPResponse.handleSuccessResponse(result: response)
                self.successState.send(otpState)
            }
            .store(in: &cancallbles)
    }
}

