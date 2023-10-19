//
//  File.swift
//  
//
//  Created by Ahmed Naguib on 18/10/2023.
//

import Foundation
import Combine

protocol ConfigOTPResponseType {
    func handleSuccessResponse(result: CreateOtpResponse) -> AnyPublisher<ConfigOTPResponse.State, Never>
}

final class ConfigOTPResponse: ConfigOTPResponseType {
    func handleSuccessResponse(result: CreateOtpResponse) -> AnyPublisher<State, Never> {
        if let limitExceededMsg = result.limitExceededMsg,
           !limitExceededMsg.isEmpty,
           let limitExceededTitle = result.limitExceededTitle,
           !limitExceededTitle.isEmpty {
            return Just(.showLimitExceedPopup(title: limitExceededTitle, subTitle: limitExceededMsg)).eraseToAnyPublisher()
            
        } else if result.responseCode == "2023" { //app integrity failed
            return Just(.showAlertWithOkayOnly(message: result.errorMsg.asStringOrEmpty(),
                                               title: result.errorTitle.asStringOrEmpty())).eraseToAnyPublisher()
        } else if result.responseCode == "1" {
            return Just(.showAlertWithOkayOnly(message: result.responseMsg.asStringOrEmpty(),
                                               title: result.errorTitle.asStringOrEmpty())).eraseToAnyPublisher()
        } else {
            if result.responseMsg != nil,
               let limitExceededMsg = result.limitExceededMsg,
               !limitExceededMsg.isEmpty,
               let limitExceededTitle = result.limitExceededTitle,
               !limitExceededTitle.isEmpty {
                return Just(.showLimitExceedPopup(title: limitExceededTitle,
                                                  subTitle: limitExceededMsg)).eraseToAnyPublisher()
            } else {
                return Just(.navigateToVerifyOTP(timeOut: result.timeout ?? 0,
                                                 header: result.otpHeaderText)).eraseToAnyPublisher()
            }
        }
    }
}

extension ConfigOTPResponse {
    enum State {
        case showLimitExceedPopup(title: String, subTitle: String)
        case showAlertWithOkayOnly(message: String, title: String)
        case navigateToVerifyOTP(timeOut: Int, header: String?)
    }
}
