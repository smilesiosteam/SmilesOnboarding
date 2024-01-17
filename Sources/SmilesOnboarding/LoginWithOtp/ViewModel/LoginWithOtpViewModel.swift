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
import SmilesLanguageManager
import SmilesUtilities

class LoginWithOtpViewModel: NSObject {
    // MARK: -- Variables
    private var output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private var baseURL: String
    private let emailStatusUseCase: EmailStatusUseCaseProtocol
    private let profileStatusUseCase: GetProfilseStatusUseCaseProtocol = GetProfileStatusUseCase()
    
    // MARK: - Init
    public init(baseURL: String, emailStatusUseCase: EmailStatusUseCaseProtocol = EmailStatusUseCase()) {
        self.baseURL = baseURL
        self.emailStatusUseCase = emailStatusUseCase
    }
}


extension LoginWithOtpViewModel {
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        output = PassthroughSubject<Output, Never>()
        input.sink { [weak self] event in
            switch event {
            case .getCountriesList(let lastModifiedDate, let firstCall):
                self?.getCountries(lastModifiedDate: lastModifiedDate, firstCall: firstCall, baseURL: self?.baseURL ?? "")
            case .getOTPforMobileNumber(mobileNumber: let mobileNumber, enableDeviceSecurityCheck: _):
                self?.didGetDeviceAppValidationData(mobileNumber: mobileNumber, captchaText: "", deviceCheckToken: "", appAttestation: "", challenge: "")
            case .loginAsGuestUser:
                self?.loginAsGuestUser()
            case .getProfileStatus(msisdn: let msisdn, authToken: let authToken):
                self?.getProfileStatus(msisdn: msisdn, authToken: authToken)
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    
    func getCountries(lastModifiedDate: String ,firstCall: Bool, baseURL: String) {
        self.output.send(.showLoader(shouldShow: true))
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
                    self?.output.send(.showLoader(shouldShow: false))
                    self?.output.send(.fetchCountriesDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response in
                debugPrint("got my response here \(response)")
                self?.output.send(.showLoader(shouldShow: false))
                if response.countryList?.count ?? 0 > 0 {
                    self?.output.send(.fetchCountriesDidSucceed(response: response))
                    CountryListResponse.saveCountryListResponse(countries: response)
                } else {
                    if CountryListResponse.isCountriesListAvailableInCache() {
                        if let res = CountryListResponse.getCountryListResponse(), let list = res.countryList, list.count > 0 {
                            self?.output.send(.fetchCountriesDidSucceed(response: res))
                        }
                    } else {
                        self?.output.send(.errorOutPut(error: (response.responseMsg ?? response.errorMsg) ?? "Error"))
                    }
                }
            }
        .store(in: &cancellables)
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
    
    func loginAsGuestUser() {
        self.output.send(.showLoader(shouldShow: true))
        let request = GuestUserRequestModel(operationName: "/login/login-guest-user")
        
        let service = LoginWithOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60), baseURL: baseURL,
            endPoint: .loginAsGuest
        )
        
        service.loginAsGuest(request: request)
            .sink { [weak self] completion   in
                debugPrint(completion)
                switch completion {
                case .failure(let error):
                    self?.output.send(.showLoader(shouldShow: false))
                    self?.output.send(.loginAsGuestDidFail(error: error))
                case .finished:
                    debugPrint("nothing much to do here")
                }
            } receiveValue: { [weak self] response  in
                self?.output.send(.showLoader(shouldShow: false))
                self?.output.send(.loginAsGuestDidSucceed(response: response))
            }
            .store(in: &cancellables)
    }
    
    func checkEmailStatus(mobileNumber: String) {
        output.send(.showLoader(shouldShow: true))
        emailStatusUseCase.checkEmailStatus(mobileNumber: mobileNumber)
            .sink { [weak self] states in
                self?.output.send(.showLoader(shouldShow: false))
                switch states {
                    
                case .showError(error: let error):
                    self?.output.send(.errorOutPut(error: error.localizedDescription))
                case .navigateToEmailVerification(message: let message):
                    self?.output.send(.navigateToEmailVerification(message: message))
                case .showLimitExceedPopup(title: let title, subTitle: let subTitle):
                    self?.output.send(.showLimitExceedPopup(title: title, subTitle: subTitle))
                case .showAlertWithOkayOnly(message: let message, _):
                    self?.output.send(.errorOutPut(error: message))
                }
            }.store(in: &cancellables)
    }
    func getProfileStatus(msisdn: String , authToken: String) {
        
        profileStatusUseCase.getProfileStatus(msisdn: msisdn, authToken: authToken)
            .sink { [weak self] completion in
                if case.failure(let error) = completion {
                    self?.output.send(.getProfileStatusDidFail(error: error))
                }
            } receiveValue: { [weak self] response in
                self?.output.send(.getProfileStatusDidSucceed(response: response))
            }.store(in: &cancellables)

    }
}
