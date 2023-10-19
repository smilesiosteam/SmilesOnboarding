//
//  File.swift
//  
//
//  Created by Ahmed Naguib on 17/10/2023.
//

import Foundation
import SmilesUtilities

enum OnboardingLocalizationKeys: String {
    case sendCode
    case verifyEmail
    case enterEmail
    case verifyEmailDescription
    case verificationCodeSentOverMail
    case continueText
    case noTitleError
    case enterEmailID
    var text: String {
        switch self {
            
        case .sendCode:
           return "sendCodeTitle".localizedString
        case .verifyEmail:
            return "onboardingVerifyEmail".localizedString
        case .enterEmail:
            return "onboardingEnterEmail".localizedString
        case .verifyEmailDescription:
            return "onboardingVerifyEmailDescription".localizedString
        case .verificationCodeSentOverMail:
            return "onboardingVerificationCodeSentOverMail".localizedString
        case .continueText:
            return "ContinueText".localizedString
        case .noTitleError:
            return "NoNet_Title".localizedString
        case .enterEmailID:
            return "onboardingEnterEmailID".localizedString
        }
    }
}
