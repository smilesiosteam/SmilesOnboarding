//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 24/06/2023.
//

import Foundation
import UIKit

public enum LoginType : String {
    case otp, touchId ,none
}

enum LoginFlow {
    case internationalNumber // The normal flow
    case email(email: String, mobile: String) // Users outside UAE
    case verifyEmail(email: String, mobile: String) // The last Stage for verification
    
    var otpTitleText: String {
        switch self {
        case .internationalNumber, .verifyEmail:
            return "verifyOtpTitle".localizedString
        case .email:
           return OnboardingLocalizationKeys.verifyEmail.text
        }
    }
    
    var otpDescriptionText: String {
        switch self {
        case .internationalNumber, .verifyEmail:
            return "verifyOtpdesc".localizedString
        case .email:
           return OnboardingLocalizationKeys.verificationCodeSentOverMail.text
        }
    }
    
    var otpType: String {
        switch self {
        case .internationalNumber:
            return "SMS"
        case .email, .verifyEmail:
            return "EMAIL"
        }
    }
}

@objc public class OnBoardingModuleManager: NSObject {
        
    @objc public static func instantiateLoginWithOtpViewController(storyBoardName: String, controller: String, baseUrl: String) -> LoginWithOtpViewController? {
        let storyboard = UIStoryboard(name: storyBoardName, bundle: .module)
        let viewController = storyboard.instantiateViewController(identifier: controller, creator: { coder in
            LoginWithOtpViewController(coder: coder, baseURL: baseUrl)
        })
        return viewController
    }
    
    @objc public static func instantiateCountryCodeViewController() -> CountriesListViewController? {
        let storyboard = UIStoryboard(name: "CountriesListStoryBoard", bundle: .module)
        let viewController = storyboard.instantiateViewController(identifier: "CountriesListViewController", creator: { coder in
            CountriesListViewController(coder: coder)
        })
        return viewController
    }
}
