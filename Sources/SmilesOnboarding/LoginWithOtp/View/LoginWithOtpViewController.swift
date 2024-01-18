//
//  LoginWithOtpViewController.swift
//  
//
//  Created by Shahroze Zaheer on 20/06/2023.
//

import UIKit
import Foundation
import SmilesUtilities
import Combine
import PhoneNumberKit
import SmilesLanguageManager
import SmilesLoader
import SmilesBaseMainRequestManager
import NetworkingLayer

@objc public class LoginWithOtpViewController: UIViewController {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var termsBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel! {
        didSet {
            errorLabel.fontTextStyle = .smilesBody3
        }
    }
    
    @IBOutlet weak var changeLangBtn: UIButton! {
        didSet {
            changeLangBtn.fontTextStyle = .smilesHeadline3
            if SmilesLanguageManager.shared.currentLanguage == .en {
                changeLangBtn.setTitle("arabicTitle".localizedString, for: .normal)
            } else {
                changeLangBtn.setTitle("EnglishTitle".localizedString, for: .normal)
            }
        }
    }
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
    @IBOutlet weak var countiresFieldView: UIView! {
        didSet {
            countiresFieldView.layer.cornerRadius = 12
            countiresFieldView.layer.borderWidth = 1
            countiresFieldView.layer.borderColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.2).cgColor
        }
    }
    @IBOutlet weak var countryFlagImg: UIImageView!
    @IBOutlet weak var countryName: UILabel! {
        didSet {
            countryName.fontTextStyle = .smilesTitle1
        }
    }
    @IBOutlet weak var downArrowImg: UIImageView!
    
    @IBOutlet weak var mobileNumberFieldView: UIView! {
        didSet {
            mobileNumberFieldView.layer.cornerRadius = 12
            mobileNumberFieldView.layer.borderWidth = 1
            mobileNumberFieldView.layer.borderColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.2).cgColor
        }
    }
    
    @IBOutlet weak var countryCodeLbl: UILabel! {
        didSet {
            countryCodeLbl.fontTextStyle = .smilesBody3
        }
    }
    @IBOutlet weak var mobileNumberTxtField: UITextField! {
        didSet {
            mobileNumberTxtField.delegate = self
            mobileNumberTxtField.fontTextStyle = .smilesTitle1
        }
    }
    
    @IBOutlet weak var termsAndCondLbl: UILabel! {
        didSet {
            termsAndCondLbl.fontTextStyle = .smilesBody3
        }
    }
    @IBOutlet weak var sendCodeBtn: UIButton! {
        didSet {
            sendCodeBtn.fontTextStyle = .smilesTitle1
            sendCodeBtn.layer.cornerRadius = 24
        }
    }
    @IBOutlet weak var touchIdView: UIView!
    
    @IBOutlet weak var touchIdImage: UIImageView!
    @IBOutlet weak var touchIdTtitle: UILabel! {
        didSet {
            touchIdTtitle.fontTextStyle = .smilesBody3
        }
    }
    @IBOutlet weak var guestUserBtn: UIButton!
    
    //MARK: Variables
    var input: PassthroughSubject<LoginWithOtpViewModel.Input, Never> = .init()
    private var viewModel: LoginWithOtpViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var countriesList: CountryListResponse?
    private var baseURL: String = ""
    private let phoneNumberKit = PhoneNumberKit()
    private var mobileNumber = ""
    public var isComingFromGuestPopup = false
    public var shouldShowTouchId = false
    @Published private var isUaeCitizen = true
    
    //MARK: CallBacks
    public var termsAndConditionTappCallback: (() -> Void)?
    public var loginAsGuestUserCallback:((String) -> Void)?
    public var navigateToRegisterViewCallBack: ((String, String, LoginType, Bool, [CountryList], LoginFlow) -> Void)?
    public var loginWithTouchIdCallback: (() -> Void)?
    public var sendCountryListToVcCallback: (([CountryList]) -> Void)?
    public var navigateToHomeViewControllerCallBack: ((String, String) -> Void)?
    public var languageChangeCallback: (() -> Void)?
    public var getProfileStatusDidSuccess: ((_ response: GetProfileStatusResponse) -> Void)?
    public var getProfileStatusDidFail: ((_ error: NetworkError) -> Void)?
    
    public var authenticateTouchIdDidSucceed: ((_ response: EnableTouchIdResponseModel) -> Void)?
    public var authenticateTouchIdDidfail: ((_ error: NetworkError) -> Void)?
    
    public var loginTouchIdDidSucceed: ((_ response: FullAccessLoginResponse) -> Void)?
    public var loginTouchIdDidFail: ((_ error: NetworkError) -> Void)?
    
    public init?(coder: NSCoder, baseURL: String) {
        super.init(coder: coder)
        self.baseURL = baseURL
        viewModel = LoginWithOtpViewModel(baseURL: baseURL)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
        getCountiresFromWebService()
        enableSendCodeButton(isEnable: false)
        setupGuestButton()
        setupTermsButton()
        setupStrings()
        checkIfUserUAECitizen()
        mobileNumberTxtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        setupTouchId()
    }
    
    //MARK: Binding
    
    func bind(to viewModel: LoginWithOtpViewModel) {
        input = PassthroughSubject<LoginWithOtpViewModel.Input, Never>()
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchCountriesDidSucceed(response: let response):
                    self?.countriesList = response
                    self?.sendCountryListToVcCallback?(response.countryList ?? [])
                    self?.populateUIViewWithCountry(country: self?.getCurrentCountry())
                case .fetchCountriesDidFail(error: let error):
                    self?.errorLabel.isHidden = false
                    self?.errorLabel.text = error.localizedDescription
                case .getOTPforMobileNumberDidSucceed(response: let response):
                    self?.configureGetOtpForNumber(result: response)
                case .getOTPforMobileNumberDidFail(error: let error):
                    self?.errorLabel.isHidden = false
                    self?.errorLabel.text = error.localizedDescription
                case .showLoader(shouldShow: let shouldShow):
                    shouldShow ? SmilesLoader.show(isClearBackground: false) : SmilesLoader.dismiss()
                case .loginAsGuestDidSucceed(response: let response):
                    if let token = response.guestSessionDetails?.authToken {
                        self?.loginAsGuestUserCallback?(token)
                    }
                case .loginAsGuestDidFail(error: let error):
                    self?.errorLabel.isHidden = false
                    self?.errorLabel.text = error.localizedDescription
                case .errorOutPut(error: let error):
                    DispatchQueue.main.async {
                        self?.showAlertWithOkayOnly(message: error, title: "NoNet_Title".localizedString)
                    }
                case .navigateToEmailVerification(message: let message):
                    self?.navigateToEmailVerification(message: message)
                case .showLimitExceedPopup(title: let title, subTitle: let subTitle):
                    self?.showLimitExceedPopup(title: title, subTitle: subTitle)
                case .getProfileStatusDidSucceed(response: let response):
                    debugPrint(response)
                    self?.getProfileStatusDidSuccess?(response)
                case .getProfileStatusDidFail(error: let error):
                    debugPrint(error)
                    self?.getProfileStatusDidFail?(error)
                case .authenticateTouchIdDidSucceed(response: let response):
                    debugPrint(response)
                    self?.authenticateTouchIdDidSucceed?(response)
                case .authenticateTouchIdDidfail(error: let error):
                    debugPrint(error)
                    self?.authenticateTouchIdDidfail?(error)
                case .loginTouchIdDidSucceed(response: let response):
                    self?.loginTouchIdDidSucceed?(response)
                case .loginTouchIdDidFail(error: let error):
                    self?.loginTouchIdDidFail?(error)
                }
            }.store(in: &cancellables)
    }
    public func authenticateTouchIdCalledFromOnBoarding(token: String, isEnabled: Bool) {
        self.input.send(.authenticateTouchId(token: token, isEnabled: isEnabled))
    }
   public func getProfileStatusRequestFromOnBoarding(mobNum: String,token: String) {
       self.input.send(.getProfileStatus(msisdn: mobNum, authToken: token))
    }
    public func loginTouchIdCalledFromOnboarding(_ token: String) {
        self.input.send(.loginTouchId(token))
    }
    func getCountiresFromWebService() {
        var firstCall = true
        var lastModifiedDate = ""
        if let countryListResponse = CountryListResponse.getCountryListResponse() {
            firstCall = false
            lastModifiedDate = countryListResponse.lastModifiedDate.asStringOrEmpty()
        }
        self.input.send(.getCountriesList(lastModifiedDate: lastModifiedDate, firstCall: firstCall))
    }
    
    private func checkIfUserUAECitizen() {
        $isUaeCitizen.sink { [weak self] isCitizen in
            let text = isCitizen ? OnboardingLocalizationKeys.sendCode.text : OnboardingLocalizationKeys.continueText.text
            self?.sendCodeBtn.setTitle(text, for: .normal)
        }.store(in: &cancellables)
    }
    @IBAction func termsBtnTapped(_ sender: Any) {
        self.termsAndConditionTappCallback?()
    }
    
    @IBAction func changeLangBtnTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.perform(#selector(self.changeLang), with: self, afterDelay: 0.7)
    }
    
    @IBAction func sendCodeTapped(_ sender: Any) {
        guard isUaeCitizen else {
            viewModel.checkEmailStatus(mobileNumber: mobileNumber)
            return
        }
        let enableDeviceSecurityCheck = !isValidEmiratiNumber(phoneNumber: mobileNumber)
        self.input.send(.getOTPforMobileNumber(mobileNumber: mobileNumber, enableDeviceSecurityCheck: enableDeviceSecurityCheck))
        enableSendCodeButton(isEnable: false)
    }
    
    @IBAction func countrySelectionTapped(_ sender: Any) {
        if self.countriesList?.countryList?.count ?? 0 > 0 {
            if let vc = OnBoardingModuleManager.instantiateCountryCodeViewController() {
                // Present the instantiated view controller
                vc.countriesList = self.countriesList
                vc.modalPresentationStyle = .overFullScreen
                vc.delegate = self
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func guestBtnTapped(_ sender: Any) {
        self.input.send(.loginAsGuestUser)
    }
    
    @IBAction func touchIdtapped(_ sender: Any) {
        self.loginWithTouchIdCallback?()
    }
    
    func setupStrings() {
        if SmilesLanguageManager.shared.currentLanguage == .ar {
            descLbl.textAlignment = .right
            titleLbl.textAlignment = .right
            descLbl2.textAlignment = .right
            termsAndCondLbl.textAlignment = .right
        }
        else {
            descLbl.textAlignment = .left
            titleLbl.textAlignment = .left
            descLbl2.textAlignment = .left
            termsAndCondLbl.textAlignment = .left
        }
        descLbl.text = "WelcomeText".localizedString
        titleLbl.text = "LoginTitle".localizedString
        descLbl2.text = "LoginInstructions".localizedString
        let text = isUaeCitizen ? OnboardingLocalizationKeys.sendCode.text : OnboardingLocalizationKeys.continueText.text
        sendCodeBtn.setTitle(text, for: .normal)
        termsAndCondLbl.text = "LoginTermsNew".localizedString
        mobileNumberTxtField.semanticContentAttribute = .forceLeftToRight
        mobileNumberFieldView.semanticContentAttribute = .forceLeftToRight
        countryCodeLbl.semanticContentAttribute = .forceLeftToRight
    }
    
    func configureGetOtpForNumber(result: CreateOtpResponse) {
        if let limitExceededMsg = result.limitExceededMsg, !limitExceededMsg.isEmpty, let limitExceededTitle = result.limitExceededTitle, !limitExceededTitle.isEmpty {
            self.showLimitExceedPopup(title: limitExceededTitle, subTitle: limitExceededMsg)
        }
        else if result.responseCode == "2023" { //app integrity failed

            self.showAlertWithOkayOnly(message: result.errorMsg.asStringOrEmpty(), title: result.errorTitle.asStringOrEmpty())
        } else if result.responseCode == "1" {
            self.showAlertWithOkayOnly(message: result.responseMsg.asStringOrEmpty(), title: result.errorTitle.asStringOrEmpty())
        }
        else {
            if result.responseMsg != nil {
                if let limitExceededMsg = result.limitExceededMsg, !limitExceededMsg.isEmpty, let limitExceededTitle = result.limitExceededTitle, !limitExceededTitle.isEmpty {
                    self.showLimitExceedPopup(title: limitExceededTitle, subTitle: limitExceededMsg)
                }
            }
            else {
                //Proceed to verify OTP screen
                navigateToVerifyOtp(response: result)
            }
        }
        enableSendCodeButton(isEnable: true)
    }
}

extension LoginWithOtpViewController {
    func getCurrentCountry() -> CountryList? {
        return self.countriesList?.countryList?.first { $0.iddCode?.contains("971") == true }
    }
    
    func populateUIViewWithCountry(country: CountryList?) {
        self.countryName.text = country?.countryName
        self.countryFlagImg.sd_setImage(with: URL(string: country?.flagIconUrl ?? ""))
        self.mobileNumberTxtField.text = (country?.iddCode == "971") ? "5" : ""
        self.countryCodeLbl.text = "+" + (country?.iddCode ?? "")
    }
    
    func enableSendCodeButton(isEnable: Bool) {
        if isEnable {
            sendCodeBtn.setTitleColor(.white, for: .normal)
            sendCodeBtn.backgroundColor = .appRevampPurpleMainColor
            sendCodeBtn.isUserInteractionEnabled = true
        } else {
            sendCodeBtn.setTitleColor(.appRevampLayerBorderColor, for: .normal)
            sendCodeBtn.backgroundColor = .appRevampCellBorderGrayColor
            sendCodeBtn.isUserInteractionEnabled = false
        }
    }
    
    func isValidEmiratiNumber(phoneNumber: String) -> Bool {
        let phoneRegex = "^(?:\\+971|971)(?:2|3|4|6|7|9|50|51|52|54|55|56|58)[0-9]{7}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
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
    
    
    func setupGuestButton() {
        let attrs = [
            NSAttributedString.Key.font : UIFont.montserratBoldFont(size: 14),
            NSAttributedString.Key.foregroundColor : UIColor.appPurpleColor,
            NSAttributedString.Key.underlineStyle : 1] as [NSAttributedString.Key : Any]

        let attributedString = NSMutableAttributedString(string:"")
        let buttonTitleStr = NSMutableAttributedString(string:"ContinueGuest".localizedString, attributes:attrs)
        attributedString.append(buttonTitleStr)
        self.guestUserBtn.setAttributedTitle(attributedString, for: .normal)

    }
    
    func setupTermsButton() {
        let attrs = [
            NSAttributedString.Key.font: UIFont.circularXXTTBookFont(size: 14),
            NSAttributedString.Key.foregroundColor: UIColor.appPurpleColor,
            NSAttributedString.Key.underlineStyle: 1
        ] as [NSAttributedString.Key: Any]

        let attributedString = NSMutableAttributedString(string: "")
        let buttonTitleStr = NSMutableAttributedString(string: "Terms & Conditions and Privacy Policy".localizedString, attributes: attrs)
        attributedString.append(buttonTitleStr)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        self.termsBtn.contentVerticalAlignment = .top
        self.termsBtn.setAttributedTitle(attributedString, for: .normal)
        if SmilesLanguageManager.shared.currentLanguage == .ar {
            self.termsBtn.contentHorizontalAlignment = .right
        } else {
            self.termsBtn.contentHorizontalAlignment = .left
        }
    }

    
    func setupTouchId() {
        self.touchIdImage.image = UIImage(named: self.setUseTouchIdImage())
        self.touchIdTtitle.text = self.setUseTouchIdTitle()
        self.touchIdView.isHidden = !shouldShowTouchId
    }
    
    func navigateToVerifyOtp(response: CreateOtpResponse) {

        var otpTimeOut = 0
        var otpHeaderText: String?
        if let headerText = response.otpHeaderText, !headerText.isEmpty {
            otpHeaderText = headerText
        }
        if let timeout = response.timeout, timeout > 0 {
            otpTimeOut = timeout
        }
        
        let navigateToRegisterViewCallBack: NewUserCallBack? = { [weak self] msisdn, token, loginType, isExistingUser, loginFlow in
            guard let self else { return }
            self.navigateToRegisterViewCallBack?(msisdn, token, loginType, isExistingUser, self.countriesList?.countryList ?? [], loginFlow)
        }
        let navigateToHomeViewControllerCallBack: OldUserCallBack? = { [weak self] msisdn, token in
            guard let self else { return }
            self.navigateToHomeViewControllerCallBack?(msisdn, token)
        }
        
        var dependance = VerifyOtpViewController.Dependance(otpTimeOut: otpTimeOut,otpHeader: otpHeaderText,
                                                            baseURL: baseURL,
                                                            mobileNumber: mobileNumber,
                                                            navigateToRegisterViewCallBack: navigateToRegisterViewCallBack,
                                                            navigateToHomeViewControllerCallBack: navigateToHomeViewControllerCallBack)
        dependance.loginFlow = .localNumber
        let viewController = OnBoardingConfigurator.getViewController(type: .navigateToVerifyOTP(dependance: dependance))
        navigationController?.pushViewController(viewController: viewController)
    }
    
    private func navigateToEmailVerification(message: String?) {
        let languageChangeCallback: (() -> Void)? = { [weak self] in
            self?.changeLang()
        }
        
        let navigateToRegisterViewCallBack: NewUserCallBack? = { [weak self] msisdn, token, loginType, isExistingUser, loginFlow in
            guard let self else { return }
            self.navigateToRegisterViewCallBack?(msisdn, token, loginType, isExistingUser, self.countriesList?.countryList ?? [], loginFlow)
        }
        let navigateToHomeViewControllerCallBack: OldUserCallBack? = { [weak self] msisdn, token in
            guard let self else { return }
            self.navigateToHomeViewControllerCallBack?(msisdn, token)
        }
        let viewController = OnBoardingConfigurator.getViewController(type: .loginWitEmail(mobileNumber: mobileNumber, baseUrl: baseURL, message: message, languageChangeCallback: languageChangeCallback, newUserCallBack: navigateToRegisterViewCallBack, oldUserCallBack: navigateToHomeViewControllerCallBack))
        navigationController?.pushViewController(viewController: viewController)
    }
    
    @objc func changeLang() {
        if SmilesLanguageManager.shared.currentLanguage == .en {
            self.languageChangeCallback?()
            changeLangBtn.setTitle("EnglishTitle".localizedString, for: .normal)
            descLbl.textAlignment = .right
            titleLbl.textAlignment = .right
            descLbl2.textAlignment = .right
            termsAndCondLbl.textAlignment = .right
        }
        else {
            self.languageChangeCallback?()
            changeLangBtn.setTitle("arabicTitle".localizedString, for: .normal)
            descLbl.textAlignment = .left
            titleLbl.textAlignment = .left
            descLbl2.textAlignment = .left
            termsAndCondLbl.textAlignment = .left
        }
        var firstCall = true
        var lastModifiedDate = ""
        if let countryListResponse = CountryListResponse.getCountryListResponse() {
            firstCall = false
            lastModifiedDate = countryListResponse.lastModifiedDate.asStringOrEmpty()
        }
        self.input.send(.getCountriesList(lastModifiedDate: lastModifiedDate, firstCall: firstCall))
        setupGuestButton()
        setupTermsButton()
        setupTouchId()
        setupStrings()
        reloadViewControllerAfterChangeLanguage()
        isUaeCitizen = true
    }
    
    func reloadViewControllerAfterChangeLanguage() {
        let windows = UIApplication.shared.windows
        for window: UIWindow in windows {
            for view: UIView in window.subviews {
                view.removeFromSuperview()
                window.addSubview(view)
            }
        }
    }
    
    func setUseTouchIdTitle() -> String {
        return UIDeviceHelper().isIphoneX() ? "UseFaceId".localizedString : "UseTouchID".localizedString
    }
    
    func setUseTouchIdImage() -> String {
        return UIDeviceHelper().isIphoneX() ? "face_id_consumer" : "TouchID"
    }
}


extension LoginWithOtpViewController: UITextFieldDelegate {
    @objc func textFieldDidChange(_ textField: UITextField) {
        if !self.errorLabel.isHidden {
            self.errorLabel.isHidden = true
        }
        
        let currentText = textField.text ?? ""
        
        // Validate the phone number
        let phoneNumber = (self.countryCodeLbl.text ?? "") + currentText
        let isValid = phoneNumberKit.isValidPhoneNumber(phoneNumber)
        
        if isValid {
            // Valid phone number
            enableSendCodeButton(isEnable: true)
            self.mobileNumber = phoneNumber
        } else {
            // Invalid phone number
            enableSendCodeButton(isEnable: false)
        }
    }

}

extension LoginWithOtpViewController: CountrySelectionDelegate {
    public func didSelectCountry(_ country: CountryList) {
        let uaeCountryCode = 186
        let selectedCountryCode = country.countryId ?? 0
        isUaeCitizen = uaeCountryCode == selectedCountryCode
        populateUIViewWithCountry(country: country)
        enableSendCodeButton(isEnable: false)
    }
}
