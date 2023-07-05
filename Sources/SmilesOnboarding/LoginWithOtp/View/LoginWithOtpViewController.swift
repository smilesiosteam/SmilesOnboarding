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

@objc public class LoginWithOtpViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var titleLbl: UILabel! {
        didSet {
            //            titleLbl.fontTextStyle = .smilesBody1
        }
    }
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var mainView: UIView! {
        didSet {
            mainView.layer.cornerRadius = 20
            mainView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            mainView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var descLbl2: UILabel!
    @IBOutlet weak var countiresFieldView: UIView! {
        didSet {
            countiresFieldView.layer.cornerRadius = 12
            countiresFieldView.layer.borderWidth = 1
            countiresFieldView.layer.borderColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.2).cgColor
        }
    }
    @IBOutlet weak var countryFlagImg: UIImageView!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var downArrowImg: UIImageView!
    
    @IBOutlet weak var mobileNumberFieldView: UIView! {
        didSet {
            mobileNumberFieldView.layer.cornerRadius = 12
            mobileNumberFieldView.layer.borderWidth = 1
            mobileNumberFieldView.layer.borderColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.2).cgColor
        }
    }
    
    @IBOutlet weak var countryCodeLbl: UILabel!
    @IBOutlet weak var mobileNumberTxtField: UITextField! {
        didSet {
            mobileNumberTxtField.delegate = self
        }
    }
    
    @IBOutlet weak var termsAndCondLbl: UILabel!
    @IBOutlet weak var sendCodeBtn: UIButton! {
        didSet {
            sendCodeBtn.layer.cornerRadius = 24
        }
    }
    @IBOutlet weak var touchIdView: UIView!
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
        termsAndCondLbl.attributedText = getAgreetoTermsAndConditionText(hint: "By continuing, I agree to Smiles by Etisalat’s Terms & conditions and privacy policy")
        setupGuestButton()
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
                    self?.populateUIViewWithCountry(country: self?.getCurrentCountry())
                case .fetchCountriesDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                case .generateCaptchaDidSucced(response: let response):
                    guard let data = response else {return}
                    self?.configureGetCaptchaData(response: data)
                case .generateCaptchaDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                case .getOTPforMobileNumberDidSucceed(response: let response):
                    self?.configureGetOtpForNumber(result: response)
                case .getOTPforMobileNumberDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                case .showLoader(shouldShow: let shouldShow):
                    shouldShow ? SmilesLoader.show(isClearBackground: true) : SmilesLoader.dismiss()

                }
            }.store(in: &cancellables)
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
    
    @IBAction func sendCodeTapped(_ sender: Any) {
        let mobileNum = String(mobileNumber.dropFirst())
        self.input.send(.generateCaptcha(mobileNumber: mobileNum))
    }
    
    @IBAction func countrySelectionTapped(_ sender: Any) {
        let moduleStoryboard = UIStoryboard(name: "CountriesListStoryBoard", bundle: .module)
        if let vc = moduleStoryboard.instantiateViewController(withIdentifier: "CountriesListViewController") as? CountriesListViewController {
            // Present the instantiated view controller
            vc.countriesList = self.countriesList
            vc.modalPresentationStyle = .overFullScreen
            vc.delegate = self
            present(vc, animated: true, completion: nil)
        }
    }
    
    func configureGetCaptchaData(response: CaptchaResponseModel) {
        if let captchaString = response.captchaDetails?.captcha, !captchaString.isEmpty, let timer = response.captchaDetails?.captchaExpiry, timer > 0 {
            print("Captcha exists, navigate to captcha screen with captcha")
            //TODO: Captcha Redirection
//            self.loginDelegate?.didGetCaptchWithString(captchaString: captchaString,mobileNumber: mobileNumber, and: timer)
        } else {
            if let limitExceededMsg = response.limitExceededMsg, !limitExceededMsg.isEmpty, let limitExceededTitle = response.limitExceededTitle, !limitExceededTitle.isEmpty {
                self.showLimitExceedPopup(title: limitExceededTitle, subTitle: limitExceededMsg)
                
            } else if response.responseCode == "2012" || response.responseCode == "2013" || response.responseCode == "2011" || response.responseCode == "2010" { //Maximum
                self.showLimitExceedPopup(title: response.errorTitle.asStringOrEmpty(), subTitle: response.errorMsg.asStringOrEmpty())
                
            } else {
                // proceed to OTP
                let enableDeviceSecurityCheck = !isValidEmiratiNumber(phoneNumber: mobileNumber)
                self.input.send(.getOTPforMobileNumber(mobileNumber: mobileNumber, enableDeviceSecurityCheck: enableDeviceSecurityCheck))
            }
        }
    }
    
    func configureGetOtpForNumber(result: CreateOtpResponse) {
        if let limitExceededMsg = result.limitExceededMsg, !limitExceededMsg.isEmpty, let limitExceededTitle = result.limitExceededTitle, !limitExceededTitle.isEmpty {
            self.showLimitExceedPopup(title: limitExceededTitle, subTitle: limitExceededMsg)
        }
        else if result.responseCode == "2023" { //app integrity failed

            self.showAlertWithOkayOnly(message: result.errorMsg.asStringOrEmpty(), title: result.errorTitle.asStringOrEmpty())
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
    
    func getAgreetoTermsAndConditionText(hint: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: hint, attributes: [
            .font: UIFont.circularXXTTBookFont(size: 14),
            .foregroundColor: #colorLiteral(red: 0.5019607843, green: 0.5019607843, blue: 0.5019607843, alpha: 1),
            .kern: 0.0
        ])
        var range = (hint as NSString).range(of: "Terms & conditions and privacy policy")
        if SmilesLanguageManager.shared.currentLanguage == .ar {
            range = NSRange(location: 9, length: hint.count - 9)
        }
        attributedString.addAttributes([.foregroundColor: UIColor.appPurpleColor1,
                                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                                        .font: UIFont.circularXXTTBookFont(size: 14)], range: range)
        
        return attributedString
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
    
    func navigateToVerifyOtp(response: CreateOtpResponse) {
        var otpTimeOut = 0
        var otpHeaderText: String?
        if let headerText = response.otpHeaderText, !headerText.isEmpty {
            otpHeaderText = headerText
        }
        if let timeout = response.timeout, timeout > 0 {
            otpTimeOut = timeout
        }
        
        let moduleStoryboard = UIStoryboard(name: "VerifyOtpStoryboard", bundle: .module)
        let vc = moduleStoryboard.instantiateViewController(identifier: "VerifyOtpViewController", creator: { coder in
            VerifyOtpViewController(coder: coder, baseURL: self.baseURL)
        })
        vc.otpHeaderText = otpHeaderText
        vc.otpTimeOut = otpTimeOut
        vc.mobileNumber = self.mobileNumber
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


extension LoginWithOtpViewController: UITextFieldDelegate {
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Get the updated text with the replacement string
        let currentText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
        
        // Validate the phone number
        let phoneNumber =  (self.countryCodeLbl.text ?? "") + currentText
        let isValid = phoneNumberKit.isValidPhoneNumber(phoneNumber)
        
        if isValid {
            // Valid phone number
            enableSendCodeButton(isEnable: true)
            self.mobileNumber = phoneNumber
        } else {
            // Invalid phone number
            enableSendCodeButton(isEnable: false)
        }
        
        return true
    }
}

extension LoginWithOtpViewController: CountrySelectionDelegate {
    func didSelectCountry(_ country: CountryList) {
        self.populateUIViewWithCountry(country: country)
        self.enableSendCodeButton(isEnable: false)
    }
}
