//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 25/06/2023.
//

import Foundation
import Combine
import NetworkingLayer
import SmilesBaseMainRequestManager
import DeviceAppCheck

class LoginWithOtpViewModel: NSObject {
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    
    private var baseURL: String
    
    public init(baseURL: String) {
        self.baseURL = baseURL
    }
}


extension LoginWithOtpViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getCountriesList(let lastModifiedDate, let firstCall):
                self?.getCountries(lastModifiedDate: lastModifiedDate, firstCall: firstCall, baseURL: self?.baseURL ?? "")
            case .generateCaptcha(mobileNumber: let mobileNumber):
                self?.getCaptcha(num: mobileNumber)
            case .getOTPforMobileNumber(mobileNumber: let mobileNumber, enableDeviceSecurityCheck: let enableDeviceSecurityCheck):
                self?.getOtpForMobileNumber(number: mobileNumber, isSecurityCheck: enableDeviceSecurityCheck)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    
    func getCountries(lastModifiedDate: String ,firstCall: Bool, baseURL: String) {
        let request = CountryListRequest()
        request.firstCallFlag = firstCall
        request.lastModifiedDate = lastModifiedDate
        
        let service = LoginWithOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .getCountries
        )
        
        service.getAllCountriesService(request: request)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.fetchCountriesDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.fetchCountriesDidSucceed(response: response))
            }
        .store(in: &cancellables)
    }
    
    func getCaptcha(num: String) {
        let request = CaptchValidtionRequest()
        request.msisdn = num
        request.channel = ""
        request.deviceId = SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.deviceId
        request.reGenerate = false
        
        let service = LoginWithOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .getCaptcha
        )
        
        service.getCaptcha(request: request)
            .sink { [weak self] completion in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.generateCaptchaDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: {  [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.generateCaptchaDidSucced(response: response))
            }
            .store(in: &cancellables)
    }
    
    func getOtpForMobileNumber(number: String, isSecurityCheck: Bool) {
        let captchaText = ""
        if isSecurityCheck {
            DeviceAppCheck.shared.getSecurityData { dcCheck, attestation, challenge, error  in
                if error != nil {
                    let errorModel = ErrorCodeConfiguration()
                    errorModel.errorCode = -1
                    errorModel.errorDescriptionEn = "DeviceJailBreakMsgText".localizedString
                    errorModel.errorDescriptionAr = "DeviceJailBreakMsgText".localizedString
                }else{
                    self.didGetDeviceAppValidationData(mobileNumber: number, captchaText: captchaText, deviceCheckToken: dcCheck, appAttestation: attestation, challenge: challenge)
                }
            }
        } else {
            self.didGetDeviceAppValidationData(mobileNumber: number, captchaText: captchaText, deviceCheckToken: nil, appAttestation: nil, challenge: nil)
        }
    }
    
    func didGetDeviceAppValidationData(mobileNumber: String,  captchaText: String, deviceCheckToken:String?, appAttestation:String?, challenge:String?) {
        
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
