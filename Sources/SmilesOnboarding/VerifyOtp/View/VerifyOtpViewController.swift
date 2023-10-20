//
//  VerifyOtpViewController.swift
//  
//
//  Created by Shahroze Zaheer on 04/07/2023.
//

import UIKit
import Combine
import SmilesBaseMainRequestManager
import SmilesLocationHandler
import SmilesLanguageManager
import SmilesLoader
import PhoneNumberKit

public class VerifyOtpViewController: UIViewController {
    //MARK: IBOutlets
    
    @IBOutlet weak var phoneNumberText: UILabel!
    @IBOutlet weak var call101Text: UILabel!
    @IBOutlet weak var errorLblView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var titleLbl: UILabel! {
        didSet {
            titleLbl.fontTextStyle = .smilesHeadline1
        }
    }
    @IBOutlet weak var descLbl: UILabel! {
        didSet {
            descLbl.fontTextStyle = .smilesBody3
        }
    }
    @IBOutlet weak var mainView: UIView! {
        didSet {
            mainView.layer.cornerRadius = 20
            mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            mainView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var descLbl2: UILabel! {
        didSet {
            descLbl2.fontTextStyle = .smilesBody3
        }
    }
    @IBOutlet weak var backBtnView: UIView! {
        didSet {
            backBtnView.layer.cornerRadius = 16
        }
    }
    @IBOutlet weak var otpTextField: AROTPTextField! {
        didSet {
            otpTextField.fontTextStyle = .smilesHeadline2
        }
    }
    
    @IBOutlet weak var timerLabel: UILabel! {
        didSet {
            timerLabel.fontTextStyle = .smilesBody3
        }
    }
    
    @IBOutlet weak var resendBtn: UIButton! {
        didSet {
            resendBtn.fontTextStyle = .smilesBody3
        }
    }
    @IBOutlet weak var loginBtn: UIButton! {
        didSet {
            loginBtn.fontTextStyle = .smilesTitle1
            loginBtn.layer.cornerRadius = 24
        }
    }
    //MARK: Variables
    var input: PassthroughSubject<VerifyOtpViewModel.Input, Never> = .init()
    private var viewModel: VerifyOtpViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    public var otpHeaderText: String?
    public var otpTimeOut = 0
    public var mobileNumber: String?
    private var otpNumber = ""
    private var baseURL: String = ""
    private var authToken = ""
    private let touchMe = BiometricIDAuth()
    var countdownTimer: Timer?
    var timeRemaining = 0 {
        didSet {
            updateTimerLabel()
        }
    }
    let phoneNumberKit = PhoneNumberKit()
    
    //MARK: CallBacks
    var titleText = ""
    var descriptionText = ""
    var userLoginType: LoginFlow = .localNumber
    public var navigateToRegisterViewCallBack: ((String, String, LoginType, Bool) -> Void)?
    public var navigateToHomeViewControllerCallBack: ((String, String) -> Void)?
    
    public init?(coder: NSCoder, baseURL: String) {
        super.init(coder: coder)
        self.baseURL = baseURL
        viewModel = VerifyOtpViewModel(baseURL: baseURL)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
        setupUI()
        setupString()
        bindStateForEmail()
    }
    
    
    //MARK: Binding
    
    func bind(to viewModel: VerifyOtpViewModel) {
        input = PassthroughSubject<VerifyOtpViewModel.Input, Never>()
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .verifyOtpDidSucceed(response: let response):
                    if let msisdn = response.msisdn, let token = response.authToken {
                        self?.input.send(.getProfileStatus(msisdn: msisdn, authToken: token))
                    } else {
                        if let limitTitle = response.limitExceededTitle, !limitTitle.isEmpty, let limitMsg = response.limitExceededMsg, !limitMsg.isEmpty {
                            self?.showLimitExceedPopup(title: limitTitle, subTitle: limitMsg)
                        } else {
                            self?.showError((response.responseMsg ?? response.errorMsg) ?? "lbl_Error".localizedString)
                        }
                    }
                case .verifyOtpDidFail(error: let error):
                    self?.showAlertWithOkayOnly(message: error.localizedDescription)
                case .getProfileStatusDidSucceed(response: let response, msisdn: let msisdn, authToken: let authToken):
                    self?.configureProfileStatus(response: response, msisdn: msisdn, token: authToken)
                case .getProfileStatusDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                case .showLoader(shouldShow: let shouldShow):
                    shouldShow ? SmilesLoader.show(isClearBackground: false) : SmilesLoader.dismiss()
                case .getOTPforMobileNumberDidSucceed(response: let response):
                    if let time = response.timeout {
                        self?.otpTimeOut = time
                        self?.resendBtn.isHidden = true
                        self?.timerLabel.isHidden = false
                        self?.enableLoginButton(isEnable: false)
                        self?.startTimer()
                    }
                    
                case .getOTPforMobileNumberDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                }
            }.store(in: &cancellables)
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        let viewControllers = navigationController?.viewControllers ?? []
        if let loginWitEmailViewController = viewControllers.first(where: { $0 is LoginWitEmailViewController }) {
            navigationController?.popToViewController(loginWitEmailViewController, animated: true)
        } else {
            navigationController?.popViewController()
        }
    }
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        self.input.send(.verifyOtp(otp: self.otpNumber, type: userLoginType))
    }
    
    @IBAction func resendBtnTapped(_ sender: Any) {
        switch userLoginType {
        case .localNumber, .verifyMobile:
            self.input.send(.getOTPforMobileNumber(mobileNumber: self.mobileNumber.asStringOrEmpty()))
        case .verifyEmail(let email, let mobile):
            self.input.send(.getOTPForEmail(email: email, mobileNumber: mobile))
       
        }
       
    }
    
    func setupString() {
        descLbl.text = descriptionText
        descLbl2.text = "verifyOtpDesc2".localizedString
        titleLbl.text = titleText
        resendBtn.setTitle("resendOtp".localizedString, for: .normal)
        if SmilesLanguageManager.shared.currentLanguage == .ar {
            descLbl2.textAlignment = .right
            descLbl.textAlignment = .right
            titleLbl.textAlignment = .right
            backBtnView.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        }
    }
    
    func configureProfileStatus(response: GetProfileStatusResponse, msisdn: String, token: String) {
        if let status = response.profileStatus
        {
            SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.userInfo = nil
            LocationStateSaver.removeLocation()
            LocationStateSaver.removeRecentLocations()
            self.authToken = token
            self.mobileNumber = msisdn
            
            switch status {
            case 1 :
                // Check for TouchID
                enableTouchIDIfExist(number: msisdn)
            case 2 :
                // Navigate to Register User
                self.navigateToRegisterViewCallBack?(msisdn, token, .otp, false)
            case 3 :
                // Navigate to Existing User Flow
                self.navigateToRegisterViewCallBack?(msisdn, token, .otp, true)
            default:
                return
            }
        }
    }
    func enableTouchIDIfExist(number: String) {
        if !self.checkIfTouchIdEnabled()
        {
            if self.checkIfDeviceSupportToucId()
            {
                presentEnableTouchIdViewController()
            }
            else{
                navigateToHomeViewControllerCallBack?(self.mobileNumber.asStringOrEmpty(), self.authToken)
            }
            
        } else {
            
            if let mobileNumberForTouchId = self.getMobileNumberForTouchId(),!mobileNumberForTouchId.isEmpty
            {
                if self.mobileNumber == mobileNumberForTouchId {
                    navigateToHomeViewControllerCallBack?(self.mobileNumber.asStringOrEmpty(), self.authToken)
                }
                else{
                    if self.checkIfDeviceSupportToucId()
                    {
                        presentEnableTouchIdViewController()
                    }
                    else{
                        navigateToHomeViewControllerCallBack?(self.mobileNumber.asStringOrEmpty(), self.authToken)
                    }
                }
            }
            else{
                if self.checkIfDeviceSupportToucId()
                {
                    presentEnableTouchIdViewController()
                }
                else{
                    navigateToHomeViewControllerCallBack?(self.mobileNumber.asStringOrEmpty(), self.authToken)
                }
                
            }
            
        }
    }
        
    func getMobileNumberForTouchId() -> String? {
        if let numberForTouchId = UserDefaults.standard.string(forKey: "mobileNumberForTouchId"), !numberForTouchId.isEmpty {
            return numberForTouchId
        }
        return ""
    }
    
    func checkIfDeviceSupportToucId() -> Bool {
        return touchMe.canEvaluatePolicy()
    }
    
    func checkIfTouchIdEnabled() -> Bool {
        let hasTouchId = UserDefaults.standard.bool(forKey: "hasTouchId")
        return hasTouchId
    }
    
    func presentEnableTouchIdViewController() {
        let moduleStoryboard = UIStoryboard(name: "EnableTouchIdStoryboard", bundle: .module)
        let vc = moduleStoryboard.instantiateViewController(identifier: "EnableTouchIdViewController", creator: { coder in
            EnableTouchIdViewController(coder: coder, baseURL: self.baseURL)
        })
        vc.mobileNumber = self.mobileNumber ?? ""
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(vc)
        
    }
    
    func setupOtpTextFied() {
        otpTextField.otpDefaultBorderColor = .clear
        otpTextField.otpDefaultBorderWidth = 0
        otpTextField.otpFilledBorderColor = .appPurpleColor
        otpTextField.otpFilledBorderWidth = 3
        otpTextField.otpFilledBackgroundColor = .white
        otpTextField.adjustsFontSizeToFitWidth = true
        otpTextField.otpDelegate = self
        otpTextField.configure(with: 6)
    }
    
    func setupCallBtn() {
        let fullStringEn = "TroubleText".localizedString
        var phoneNumber = "call 101"
        
        if SmilesLanguageManager.shared.currentLanguage == .ar {
            phoneNumber = "تواصل علي 101"
        }
        
        let phoneNumberAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .foregroundColor: UIColor(red: 77/255, green: 81/255, blue: 103/255, alpha: 1),
            .font: UIFont.circularXXTTMediumFont(size: 14)
        ]
        
        let attributedString = NSMutableAttributedString(string: fullStringEn)
        attributedString.addAttributes(phoneNumberAttributes, range: NSRange(location: attributedString.string.count - phoneNumber.count, length: phoneNumber.count))
        
        // Set the attributed string to the label
        call101Text.attributedText = attributedString
        
        // Add a tap gesture recognizer to the label
        call101Text.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(phoneNumberTapped))
        call101Text.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func phoneNumberTapped() {
        // Call the phone number
        let phoneNumber = "101"
        if let phoneURL = NSURL(string: "tel://" + phoneNumber) {
            let alert = UIAlertController(title: "Call " + phoneNumber + "?", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Call", style: .default, handler: { _ in
                UIApplication.shared.open(phoneURL as URL, options: [:], completionHandler: nil)
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func setupPhoneNumberView() {
        do {
            let phoneNumber = try phoneNumberKit.parse(mobileNumber ?? "")
            let partialFormattedNumber = phoneNumberKit.format(phoneNumber, toType: .international)
            
            // Convert the countryCode to string
            let countryCodeString = String(phoneNumber.countryCode)
            
            // Create attributed string
            let attributedString = NSMutableAttributedString(string: partialFormattedNumber)
            
            // Set the gray color for the country code
            let countryCodeRange = NSRange(location: 0, length: countryCodeString.count)
            attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5), range: countryCodeRange)
            
            // Set the black color for the rest of the number
            let restOfNumberRange = NSRange(location: countryCodeString.count, length: partialFormattedNumber.count - countryCodeString.count)
            attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.9), range: restOfNumberRange)
            
            // Set the attributed string to the label
            phoneNumberText.attributedText = attributedString
        } catch {
            print("Error parsing the phone number: \(error)")
        }
    }
    
    func setupUI() {
        setupOtpTextFied()
        enableLoginButton(isEnable: false)
        if let otptext = otpHeaderText {
            descLbl2.text = otptext
        } else {
            descLbl2.text = "OtpHintNew".localizedString
        }
        phoneNumberText.text = mobileNumber
        setupResendButton()
        setupCallBtn()
        startTimer()
        if case .verifyEmail(email: let email, mobile: _)  = userLoginType {
            phoneNumberText.text = email
            loginBtn.setTitle(OnboardingLocalizationKeys.continueText.text, for: .normal)
        } else {
            setupPhoneNumberView()
            loginBtn.setTitle("LoginTitle".localizedString, for: .normal)
        }
    }
}

extension VerifyOtpViewController {
    func enableLoginButton(isEnable: Bool) {
        if isEnable {
            loginBtn.setTitleColor(.white, for: .normal)
            loginBtn.backgroundColor = .appRevampPurpleMainColor
            loginBtn.isUserInteractionEnabled = true
        } else {
            loginBtn.setTitleColor(.appRevampLayerBorderColor, for: .normal)
            loginBtn.backgroundColor = .appRevampCellBorderGrayColor
            loginBtn.isUserInteractionEnabled = false
        }
    }
        
    func startTimer() {
        timeRemaining = otpTimeOut
        updateTimerLabel()
        
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        } else {
            // Timer reached 0, enable the resend button
            countdownTimer?.invalidate()
            resendBtn.isHidden = false
            timerLabel.isHidden = true
        }
    }
    
    func updateTimerLabel() {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    func setupResendButton() {
        let attrs = [
            NSAttributedString.Key.font : UIFont.montserratBoldFont(size: 16),
            NSAttributedString.Key.foregroundColor : UIColor.appPurpleColor,
            NSAttributedString.Key.underlineStyle : 1] as [NSAttributedString.Key : Any]

        let attributedString = NSMutableAttributedString(string:"")
        let buttonTitleStr = NSMutableAttributedString(string:"Resend Code".localizedString, attributes:attrs)
        attributedString.append(buttonTitleStr)
        self.resendBtn.setAttributedTitle(attributedString, for: .normal)

    }
    
    func showLimitExceedPopup(title : String = "MaximumLimitExceeded".localizedString, subTitle : String) {
        let moduleStoryboard = UIStoryboard(name: "LoginWithOtpStoryboard", bundle: .module)
        if let vc = moduleStoryboard.instantiateViewController(withIdentifier: "PromptViewController") as? PromptViewController {
            // Present the instantiated view controller
            vc.titleString = title
            vc.messageString = subTitle
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true, completion: nil)
        }
    }
    
    func showError(_ text: String) {
        enableLoginButton(isEnable: false)
        errorLblView.isHidden = false
        errorLabel.text = text
        self.otpTextField.showError()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.otpTextField.clearOTP()
            self.errorLblView.isHidden = true
        }
    }
}

extension VerifyOtpViewController: EnableTouchIdDelegate {
    public func didDismissEnableTouchVC(_ viewController: UIViewController) {
        viewController.dismiss(animated: true)
        navigateToHomeViewControllerCallBack?(self.mobileNumber.asStringOrEmpty(), self.authToken)
    }
}

extension VerifyOtpViewController: AROTPTextFieldDelegate {
    public func isFinishedEnteringCode(isFinished: Bool) {
        enableLoginButton(isEnable: isFinished)
        errorLblView.isHidden = true
    }
    
    public func didUserFinishEnter(the code: String) {
        self.otpNumber = code
    }
    
}
// MARK: - Handel OTP form email verification
extension VerifyOtpViewController {
    private func bindStateForEmail() {
        viewModel.emailStatePublisher.sink { [weak self] state in
            switch state {
                
            case .showLimitExceedPopup(title: let title, subTitle: let subTitle):
                self?.showLimitExceedPopup(title: title, subTitle: subTitle)
            case .showAlertWithOkayOnly(message: let message, title: let title):
                self?.showAlertWithOkayOnly(message: message, title: title)
            case .navigateToVerifyOTP(timeOut: let timeOut, header: let header):
                self?.navigateToOTP(timeOut: timeOut, otpHeader: header)
            }
        }.store(in: &cancellables)
    }
    
    private func navigateToOTP(timeOut: Int, otpHeader: String?) {
        var dependance = VerifyOtpViewController.Dependance(otpTimeOut: timeOut,
                                           otpHeader: otpHeader,
                                           baseURL: baseURL,
                                           mobileNumber: mobileNumber ?? "",
                                           navigateToRegisterViewCallBack: navigateToRegisterViewCallBack,
                                           navigateToHomeViewControllerCallBack: navigateToHomeViewControllerCallBack)
        dependance.loginFlow = .verifyMobile(email: viewModel.userEmail, mobile: mobileNumber ?? "")
        let viewController = OnBoardingConfigurator.getViewController(type: .navigateToVerifyOTP(dependance: dependance))
        navigationController?.pushViewController(viewController: viewController)
    }
}

extension VerifyOtpViewController {
    public struct Dependance {
        var otpTimeOut: Int
        var otpHeader: String?
        var baseURL: String
        var mobileNumber: String
        var navigateToRegisterViewCallBack: NewUserCallBack?
        var navigateToHomeViewControllerCallBack: OldUserCallBack?
        var loginFlow = LoginFlow.localNumber
        var email: String?
        var titleText: String {
            return loginFlow.otpTitleText
        }
        var descriptionText: String {
            return loginFlow.otpDescriptionText
        }
    }
}
