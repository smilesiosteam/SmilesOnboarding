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
    
    func getOtpForMobileNumber(mobileNumber: String,  captchaText: String, deviceCheckToken:String?, appAttestation:String?, challenge:String?) {
        let enableDeviceSecurityCheck = !isValidEmiratiNumber(phoneNumber: mobileNumber)
        
        let captchaText = ""
                if enableDeviceSecurityCheck && OnBoardingModuleManager.isAppAttestEnabled {
                    DeviceAppCheck.shared.getSecurityData { dcCheck, attestation, challenge, error  in
                        self.output.send(.showLoader(shouldShow: false))
                        if error != nil {
                            let errorModel = ErrorCodeConfiguration()
                            errorModel.errorCode = -1
                            errorModel.errorDescriptionEn = "DeviceJailBreakMsgText".localizedString
                            errorModel.errorDescriptionAr = "DeviceJailBreakMsgText".localizedString
                            
                            print(SmilesLanguageManager.shared.currentLanguage == .en ? errorModel.errorDescriptionEn : errorModel.errorDescriptionAr)
                        } else {
                            self.didGetDeviceAppValidationData(mobileNumber: mobileNumber, captchaText: captchaText, deviceCheckToken: dcCheck, appAttestation: attestation, challenge: challenge)
                        }
                    }
                } else {
                    self.didGetDeviceAppValidationData(mobileNumber: mobileNumber, captchaText: captchaText, deviceCheckToken: nil, appAttestation: nil, challenge: nil)
                }

    }
    
    func didGetDeviceAppValidationData(mobileNumber: String,  captchaText: String, deviceCheckToken:String?, appAttestation:String?, challenge:String?) {
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
    
    
    
    
    
    func isValidEmiratiNumber(phoneNumber: String) -> Bool {
        let phoneRegex = "^(?:\\+971|971)(?:2|3|4|6|7|9|50|51|52|54|55|56|58)[0-9]{7}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
}
