//
//  File.swift
//  
//
//  Created by Ahmed Naguib on 18/10/2023.
//

import Foundation
import Combine

protocol ConfigOTPResponseType {
    func handleSuccessResponse(result: CreateOtpResponse) -> ConfigOTPResponse.State
}

final class ConfigOTPResponse: ConfigOTPResponseType {
    func handleSuccessResponse(result: CreateOtpResponse) -> State {
        if let limitExceededMsg = result.limitExceededMsg,
           !limitExceededMsg.isEmpty,
           let limitExceededTitle = result.limitExceededTitle,
           !limitExceededTitle.isEmpty {
            return .showLimitExceedPopup(title: limitExceededTitle, subTitle: limitExceededMsg)
            
        } else if result.responseCode == "2023" { //app integrity failed
            return .showAlertWithOkayOnly(message: result.errorMsg.asStringOrEmpty(), title: result.errorTitle.asStringOrEmpty())
        } else if result.responseCode == "1" {
            return .showAlertWithOkayOnly(message: result.responseMsg.asStringOrEmpty(), title: result.errorTitle.asStringOrEmpty())
        } else {
            if result.responseMsg != nil,
               let limitExceededMsg = result.limitExceededMsg,
               !limitExceededMsg.isEmpty,
               let limitExceededTitle = result.limitExceededTitle,
               !limitExceededTitle.isEmpty {
                return .showLimitExceedPopup(title: limitExceededTitle,
                                                  subTitle: limitExceededMsg)
            } else {
                return .navigateToVerifyOTP(timeOut: result.timeout ?? 0,
                                                 header: result.otpHeaderText)
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
