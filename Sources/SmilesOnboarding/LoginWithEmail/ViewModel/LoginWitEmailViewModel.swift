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
    // MARK: - Init
    init(mobileNumber: String, baseURL: String, configOTPResponse: ConfigOTPResponseType = ConfigOTPResponse()) {
        self.mobileNumber = mobileNumber
        self.baseURL = baseURL
        self.configOTPResponse = configOTPResponse
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
    func sendCode() {
        let emailEncrypted = AES256Encryption.encrypt(with: emailTextSubject.value)
        let request = OTPEmailValidationRequest(email: emailEncrypted)
        let msisdn = String(mobileNumber.dropFirst())
        request.msisdn = msisdn
        SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.msisdn = msisdn
        
        let service = LoginWithOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .getOtpForEmail
        )
        state = .showLoader(true)
        
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
                self.configOTPResponse.handleSuccessResponse(result: response)
                    .subscribe(self.successState)
                    .store(in: &cancallbles)
            }
            .store(in: &cancallbles)
        
    }
}

