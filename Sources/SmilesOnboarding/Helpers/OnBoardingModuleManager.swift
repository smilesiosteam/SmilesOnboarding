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

@objc public class OnBoardingModuleManager: NSObject {
    
    public static var isAppAttestEnabled = true
        
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
