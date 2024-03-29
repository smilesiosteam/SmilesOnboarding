//
//  File.swift
//  
//
//  Created by Ahmed Naguib on 18/10/2023.
//

import Foundation
import Combine
import NetworkingLayer

protocol LimitTimeChecker: BaseMainResponse {
    var limitExceededTitle: String? { get set }
    var limitExceededMsg: String? { get set }
    var otpHeaderText: String? { get set }
    var timeout: Int? { get set }
}

protocol ConfigOTPResponseType {
    func handleSuccessResponse(result: LimitTimeChecker) -> ConfigOTPResponse.State
}

final class ConfigOTPResponse: ConfigOTPResponseType {
    func handleSuccessResponse(result: LimitTimeChecker) -> State {
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
                return .success(timeOut: result.timeout ?? 0,
                                                 header: result.otpHeaderText)
            }
        }
    }
}

extension ConfigOTPResponse {
    enum State {
        case showLimitExceedPopup(title: String, subTitle: String)
        case showAlertWithOkayOnly(message: String, title: String)
        case success(timeOut: Int, header: String?)
    }
}
