//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 24/06/2023.
//

import Foundation
import UIKit

@objc public class OnBoardingModuleManager: NSObject {
        
    @objc public static func instantiateLoginWithOtpViewController(storyBoardName: String, controller: String, baseUrl: String) -> LoginWithOtpViewController? {
        let storyboard = UIStoryboard(name: storyBoardName, bundle: .module)
        let viewController = storyboard.instantiateViewController(identifier: controller, creator: { coder in
            LoginWithOtpViewController(coder: coder, baseURL: baseUrl)
        })
        return viewController
    }
}
