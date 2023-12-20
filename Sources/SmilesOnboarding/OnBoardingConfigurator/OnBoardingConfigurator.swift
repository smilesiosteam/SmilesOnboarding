//
//  File.swift
//  
//
//  Created by Ahmed Naguib on 17/10/2023.
//


import UIKit
import SmilesUtilities

public typealias NewUserCallBack = ((String, String, LoginType, Bool, LoginFlow) -> Void)
typealias OldUserCallBack = ((String, String) -> Void)

enum OnBoardingConfiguratorType {
    case loginWitEmail(mobileNumber: String, baseUrl: String, message: String? ,languageChangeCallback: (() -> Void)?, newUserCallBack: NewUserCallBack?, oldUserCallBack: OldUserCallBack?)
    case showLimitExceedPopup(title: String, subTitle: String)
    case navigateToVerifyOTP(dependance: VerifyOtpViewController.Dependance)
}

enum OnBoardingConfigurator {
    
    static func getViewController(type: OnBoardingConfiguratorType) -> UIViewController {
        switch type {
            
        case .loginWitEmail(mobileNumber: let mobileNumber, baseUrl: let baseUrl, let message, languageChangeCallback: let languageChangeCallback, newUserCallBack: let newUser, oldUserCallBack: let oldUser):
            return getLoginWitEmailView(mobileNumber: mobileNumber, baseUrl: baseUrl, message: message, languageChangeCallback: languageChangeCallback, newUserCallBack: newUser, oldUserCallBack: oldUser)
        case .showLimitExceedPopup(title: let title, subTitle: let subTitle):
            return showLimitExceedPopup(title: title, subTitle: subTitle)
        case .navigateToVerifyOTP(dependance: let dependance):
            return navigateToVerifyOTP(dependance: dependance)
        }
    }
    
    static private func getLoginWitEmailView(mobileNumber: String, 
                                             baseUrl: String,
                                             message: String?,
                                             languageChangeCallback: (() -> Void)?,
                                             newUserCallBack: NewUserCallBack?,
                                             oldUserCallBack: OldUserCallBack?) -> UIViewController  {
        let viewModel = LoginWitEmailViewModel(mobileNumber: mobileNumber, baseURL: baseUrl)
        let viewController = LoginWitEmailViewController(nibName: String(describing: LoginWitEmailViewController.self), bundle: Bundle.module)
        viewController.navigateToHomeViewControllerCallBack = oldUserCallBack
        viewController.navigateToRegisterViewCallBack = newUserCallBack
        viewController.viewModel = viewModel
        viewController.languageChangeCallback = languageChangeCallback
        viewController.message = message
        return viewController
    }
    
    static private func showLimitExceedPopup(title: String, subTitle: String) -> UIViewController {
        let moduleStoryboard = UIStoryboard(name: "LoginWithOtpStoryboard", bundle: .module)
        let viewController = moduleStoryboard.instantiateViewController(withIdentifier: "PromptViewController") as? PromptViewController
        viewController?.titleString = title
        viewController?.messageString = subTitle
        viewController?.modalPresentationStyle = .overCurrentContext
        viewController?.modalTransitionStyle = .crossDissolve
        return viewController ?? UIViewController()
    }
    
    static private func navigateToVerifyOTP(dependance: VerifyOtpViewController.Dependance) -> UIViewController {
        let moduleStoryboard = UIStoryboard(name: "VerifyOtpStoryboard", bundle: .module)
        let viewController = moduleStoryboard.instantiateViewController(identifier: "VerifyOtpViewController", creator: { coder in
            VerifyOtpViewController(coder: coder, baseURL: dependance.baseURL)
        })
        viewController.navigateToRegisterViewCallBack = dependance.navigateToRegisterViewCallBack
        viewController.navigateToHomeViewControllerCallBack = dependance.navigateToHomeViewControllerCallBack
        viewController.otpHeaderText = dependance.otpHeader
        viewController.otpTimeOut = dependance.otpTimeOut
        viewController.mobileNumber = dependance.mobileNumber
        viewController.titleText = dependance.titleText
        viewController.descriptionText = dependance.descriptionText
        viewController.loginFlow = dependance.loginFlow
        return viewController
    }
}
