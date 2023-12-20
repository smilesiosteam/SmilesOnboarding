//
//  LoginWitEmailViewController.swift
//  
//
//  Created by Ahmed Naguib on 16/10/2023.
//

import UIKit
import SmilesLanguageManager
import SmilesFontsManager
import SmilesLoader
import Combine
import SmilesUtilities

final class LoginWitEmailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var backView: UIView! {
        didSet { backView.layer.cornerRadius = 16 }
    }
   
    @IBOutlet private weak var emailTextFiled: UITextField! {
        didSet { emailTextFiled.font = .circularXXTTMediumFont(size: 16) }
    }
    
    @IBOutlet private weak var sendCodeButton: UIButton! {
        didSet {
            sendCodeButton.titleLabel?.font = .circularXXTTMediumFont(size: 16)
            sendCodeButton.layer.cornerRadius = 24
            sendCodeButton.setTitle(OnboardingLocalizationKeys.sendCode.text, for: .normal)
            setButtonDisable()
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        didSet {  titleLabel.fontTextStyle = .smilesHeadline1 }
    }
    
    @IBOutlet private weak var subTitleLabel: UILabel! {
        didSet { subTitleLabel.fontTextStyle = .smilesBody3 }
    }
    
    @IBOutlet private weak var detailsLabel: UILabel! {
        didSet {
            detailsLabel.textColor = UIColor(red: 77/255, green: 81/255, blue: 103/255, alpha: 1)
            detailsLabel.font = .circularXXTTMediumFont(size: 14)
            detailsLabel.setLineHeight(lineHeight: 6)
        }
    }
    
    @IBOutlet private weak var emailView: UIView! {
        didSet {
            emailView.layer.cornerRadius = 20
            emailView.backgroundColor = .black.withAlphaComponent(0.05)
        }
    }
    
    @IBOutlet private weak var mainView: UIView! {
        didSet {
            mainView.layer.cornerRadius = 20
            mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            mainView.layer.masksToBounds = true
        }
    }
    
    // MARK: - Properties
    private var cancallbles = Set<AnyCancellable>()
    private let localization = OnboardingLocalizationKeys.self
    public var viewModel: LoginWitEmailViewModel!
   
    // MARK: - Delegate
    public var languageChangeCallback: (() -> Void)?
    public var navigateToRegisterViewCallBack: NewUserCallBack?
    public var navigateToHomeViewControllerCallBack: OldUserCallBack?
    public var message: String?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeEmailTextField()
        bindViewModelStates()
        configChangeLanguage()
        bindSuccessResponse()
    }
    
    // MARK: - Button Actions
    @IBAction private func sendCodeTapped(_ sender: Any) {
        viewModel.sendCode()
    }
    
    @IBAction func popButtonTapped(_ sender: Any) {
        navigationController?.popViewController()
    }
    // MARK: - Function UI Config
    private func subscribeEmailTextField() {
        emailTextFiled.textPublisher
            .share()
            .subscribe(viewModel.emailTextSubject)
            .store(in: &cancallbles)
    }
    
    private func setButtonDisable() {
        sendCodeButton.isUserInteractionEnabled = false
        sendCodeButton.fontTextStyle = .smilesTitle1
        sendCodeButton.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        let color: UIColor = UIColor.black.withAlphaComponent(0.5)
        sendCodeButton.setTitleColor(color, for: .normal)
    }
    
    private func setButtonEnable() {
        sendCodeButton.isUserInteractionEnabled = true
        sendCodeButton.backgroundColor = .appRevampPurpleMainColor
        sendCodeButton.setTitleColor(.white, for: .normal)
    }
    
    private func setMailTextFieldNotEmptyState() {
        emailView.backgroundColor = .clear
        emailView.layer.cornerRadius = 20
        emailView.layer.borderWidth = 1
        emailView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        emailTextFiled.textColor = .black
    }
    
    private func setMailTextFieldEmptyState() {
        emailView.backgroundColor = UIColor.black.withAlphaComponent(0.05)
        emailView.layer.borderWidth = 0
        let attributes: [NSAttributedString.Key: Any] = [ .foregroundColor: UIColor.black.withAlphaComponent(0.5)]
        let attributedPlaceholder = NSAttributedString(string: localization.enterEmailID.text, attributes: attributes)
        emailTextFiled.attributedPlaceholder = attributedPlaceholder
    }
    
    private func configChangeLanguage() {
        titleLabel.text = localization.verifyEmail.text
        subTitleLabel.text = localization.enterEmail.text
        emailTextFiled.placeholder = localization.enterEmailID.text
        detailsLabel.text = message
        sendCodeButton.setTitle(localization.sendCode.text, for: .normal)
        configAlignment()
    }
    
    private func configAlignment () {
        let isEnglish = SmilesLanguageManager.shared.currentLanguage == .en
        titleLabel.textAlignment = isEnglish ? .left : .right
        subTitleLabel.textAlignment = isEnglish ? .left : .right
        detailsLabel.textAlignment = isEnglish ? .left : .right
        emailTextFiled.textAlignment = isEnglish ? .left : .right
        if !isEnglish {
            backView.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        }
    }
    
    private func bindViewModelStates() {
        viewModel.$state.sink { [weak self] states in
            switch states {
                
            case .isValuedEmail(let isValid): self?.setButtonDisable()
                isValid ? self?.setButtonEnable() : self?.setButtonDisable()
            case .isEmailTextNotEmpty(let hasValue): self?.setMailTextFieldEmptyState()
                hasValue ?  self?.setMailTextFieldNotEmptyState() : self?.setMailTextFieldEmptyState()
            case .showLoader(let isShow):
                isShow ? SmilesLoader.show(isClearBackground: false) : SmilesLoader.dismiss()
            case .showAlertWithOkayOnly(message: let message, title: let title):
                self?.showAlertWithOkayOnly(message: message, title: title)
            }
        }
        .store(in: &cancallbles)
    }
    
    // MARK: - API States
    private func bindSuccessResponse() {
        viewModel.successState.sink { [weak self] state in
            guard let self else {
                return
            }
            switch state {
                
            case .showLimitExceedPopup(title: let title, subTitle: let subTitle):
                let viewController = OnBoardingConfigurator.getViewController(type: .showLimitExceedPopup(title: title, subTitle: subTitle))
                self.present(viewController)
            case .showAlertWithOkayOnly(message: let message, title: _):
                SmilesErrorHandler.shared.showError(on: self, error: SmilesError(description: message))
            case .success(timeOut: let timeOut, header: let header):
                self.navigateToOTP(timeOut: timeOut, otpHeader: header,
                                   baseURL: self.viewModel.baseURL,
                                   mobileNumber: self.viewModel.mobileNumber)
            }
        }
        .store(in: &cancallbles)
    }
    
    private func navigateToOTP(timeOut: Int, otpHeader: String? ,baseURL: String, mobileNumber: String) {
        var dependance = VerifyOtpViewController.Dependance(otpTimeOut: timeOut,
                                           otpHeader: otpHeader,
                                           baseURL: baseURL,
                                           mobileNumber: mobileNumber,
                                           navigateToRegisterViewCallBack: navigateToRegisterViewCallBack,
                                           navigateToHomeViewControllerCallBack: navigateToHomeViewControllerCallBack)
        dependance.loginFlow = LoginFlow.verifyEmail(email: viewModel.emailTextSubject.value, mobile: mobileNumber)
        let viewController = OnBoardingConfigurator.getViewController(type: .navigateToVerifyOTP(dependance: dependance))
        navigationController?.pushViewController(viewController: viewController)
    }
}

