//
//  File.swift
//
//
//  Created by Ahmed Naguib on 20/12/2023.
//

import Foundation
import Combine
import SmilesUtilities
import NetworkingLayer
import SmilesBaseMainRequestManager

protocol EmailStatusUseCaseProtocol {
    func checkEmailStatus(mobileNumber: String) -> AnyPublisher<EmailStatusUseCase.State, Never>
}

final class EmailStatusUseCase: EmailStatusUseCaseProtocol {
    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>()
    private let configOTPResponse: ConfigOTPResponseType
    
    // MARK: - Init
    init(configOTPResponse: ConfigOTPResponseType = ConfigOTPResponse()) {
        self.configOTPResponse = configOTPResponse
    }
    
    func checkEmailStatus(mobileNumber: String) -> AnyPublisher<State, Never> {
        let service = LoginWithOtpRepository(
            networkRequest: NetworkingLayerRequestable(requestTimeOut: 60),
            baseURL: AppCommonMethods.serviceBaseUrl,
            endPoint: .emailVerificationStatus
        )
        let request: SmilesBaseMainRequest = .init()
        let msisdn = String(mobileNumber.dropFirst())
        request.msisdn = msisdn
        SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.msisdn = msisdn
        return Future<State, Never> { [weak self] promise in
            guard let self else {
                return
            }
            service.getEmailVerificationStatus(request: request)
                .sink { completion in
                    if case .failure(let error) = completion {
                        promise(.success(.showError(error: error)))
                    }
                } receiveValue: { [weak self] response in
                    guard let self else {
                        return
                    }
                    
                    let numberRequestState = self.configOTPResponse.handleSuccessResponse(result: response)
                    switch numberRequestState {
                    case .showLimitExceedPopup(let title, let subTitle):
                        promise(.success(.showLimitExceedPopup(title: title, subTitle: subTitle)))
                    case .showAlertWithOkayOnly(let message, let title):
                        promise(.success(.showAlertWithOkayOnly(message: message, title: title)))
                    case .success:
                        let message = response.hintMessage ?? OnboardingLocalizationKeys.verifyEmailDescription.text
                        promise(.success(.navigateToEmailVerification(message: message)))
                    }
                    
                }
                .store(in: &cancellables)
        }
        .eraseToAnyPublisher()
    }
}


extension EmailStatusUseCase {
    enum State {
        case showError(error: NetworkError)
        case navigateToEmailVerification(message: String)
        case showLimitExceedPopup(title: String, subTitle: String)
        case showAlertWithOkayOnly(message: String, title: String)
    }
}
