//
//  UserRegisterationViewController.swift
//  
//
//  Created by Shmeel Ahmed on 22/06/2023.
//

import UIKit
import SmilesLanguageManager
import SmilesFontsManager
import SmilesUtilities
import Combine
import SmilesLoader

public class UserRegisterationViewController: UIViewController {
    
    @IBOutlet weak var backBtnView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var subtitleLbl: UILabel!
    
    @IBOutlet weak var firstNameLbl: UILabel!
    
    @IBOutlet weak var firstNameTxtFld: TextFieldWithValidation!
    
    @IBOutlet weak var lastNameLbl: UILabel!
    
    @IBOutlet weak var lastNameTxtFld: TextFieldWithValidation!
    
    @IBOutlet weak var emailLbl: UILabel!
    
    @IBOutlet weak var emailFld: TextFieldWithValidation!
    
    @IBOutlet weak var dobLbl: UILabel!
    
    @IBOutlet weak var dayTxtFld: TextFieldWithValidation!
    
    @IBOutlet weak var dayLbl: UILabel!
    
    @IBOutlet weak var monthTxtFld: TextFieldWithValidation!
    
    @IBOutlet weak var monthLbl: UILabel!
    
    @IBOutlet weak var yearTxtFld: TextFieldWithValidation!
    
    @IBOutlet weak var yearLbl: UILabel!
    
    @IBOutlet weak var dobPickerBtn: UIButton!
    
    @IBOutlet weak var nationalityLbl: UILabel!
    @IBOutlet weak var countryFlagImg: UIImageView!
    @IBOutlet weak var nationalityTxtFld: TextFieldWithValidation!
    
    @IBOutlet weak var genderLbl: UILabel!
    
    @IBOutlet weak var genderTxtFld: TextFieldWithValidation!
    
    @IBOutlet weak var promoLbl: UILabel!
    
    @IBOutlet weak var promoTxtFld: TextFieldWithValidation!
    
    @IBOutlet weak var termsLbl: UILabel!
    
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet var promoCodeWrapper: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var view_banner: UIView!
    @IBOutlet weak var lbl_bannerTitle: UILabel!
    @IBOutlet weak var lbl_bannerSubTitle: UILabel!
    @IBOutlet weak var constraint_bannerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var emailWrapperVu: UIView!
    @IBOutlet weak var genderWrapper: UIView!
    @IBOutlet weak var termsAndConditionsWrapper: UIView!
    
    //------------
    
    private let input: PassthroughSubject<UserRegisterationViewModel.Input, Never> = .init()
    private var viewModel: UserRegisterationViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var baseURL: String = ""
    private var genderForRequest: String?
    public var nationality:CountryList?=nil{
        didSet{
            self.nationalityTxtFld.text = nationality?.countryName
            self.countryFlagImg.sd_setImage(with: URL(string: nationality?.flagIconUrl ?? ""))
            if SmilesLanguageManager.shared.currentLanguage == .ar {
                self.nationalityTxtFld.paddingRight = 47
            } else {
                self.nationalityTxtFld.paddingLeft = 47
            }
            updateContinueButtonUI()
        }
    }
    public var nationalities:[CountryList]=[]
    public var termsAndConditions = {}
    public var didSucceedRegistration = {}
    public var registrationCompleted = {}
    public var didFailRegistration:(String?)->Void = {error in}
    public var didFailExistingVerificationFailed:(String,String,@escaping()->Void)->Void = {_,_,_ in}
    
    var dob:Date?{
        didSet{
            if let date = dob {
                dayTxtFld.text = "\(Calendar.current.component(.day, from: date))"
                monthTxtFld.text = "\(Calendar.current.component(.month, from: date))"
                yearTxtFld.text = "\(Calendar.current.component(.year, from: date))"
            }
        }
    }
    
    public var isExistingUser = false
    //MARK: - LifeCycle
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel = UserRegisterationViewModel(baseURL: self.baseURL)
        bind(to: viewModel)
        registerForKeyboardNotifications()
    }
    
    func setupUI(){
        setupTermsUI()
        titleLbl.text = !isExistingUser ? "Let’s get started".localizedString : "Verify your details".localizedString
        subtitleLbl.text = !isExistingUser ? "Tell us a few details about yourself".localizedString : nil
        firstNameTxtFld.validationType = [.requiredField(errorMessage: "EnterFirstName".localizedString)]
        firstNameLbl.text = "First Name*".localizedString
        firstNameTxtFld.continousValidation = true
        
        lastNameTxtFld.validationType = [.requiredField(errorMessage: "EnterLastName".localizedString)]
        lastNameLbl.text = "Last Name*".localizedString
        lastNameTxtFld.continousValidation = true
        
        emailWrapperVu.isHidden = isExistingUser
        genderWrapper.isHidden = isExistingUser
        termsAndConditionsWrapper.isHidden = isExistingUser
        promoCodeWrapper.isHidden = isExistingUser
        if !isExistingUser{
            emailFld.validationType = [.email(errorMessage: "InvaildEmail".localizedString)]
            emailLbl.text = "Email Address*".localizedString
            emailFld.placeholder = "e.g abcd@gmail.com".localizedString
            
            genderTxtFld.validationType = [.requiredField(errorMessage: "Select gender".localizedString)]
            genderTxtFld.continousValidation = true
            genderTxtFld.placeholder = "Select gender".localizedString
            
            genderLbl.text = "Gender*".localizedString
            
            promoLbl.text = "Have a referral/promo code?".localizedString
            continueBtn.setTitle("ContinueText".localizedString, for: .normal)
        }else{
            continueBtn.setTitle("btn_VERIFY".localizedString.capitalizingFirstLetter(), for: .normal)
        }
        
        
        dobLbl.text = "lbl_DOB".localizedString
        
        dayTxtFld.validationType = [.requiredField(errorMessage: "Please enter your Date of Birth".localizedString)]
        monthTxtFld.validationType = [.requiredField(errorMessage: " ")]
        yearTxtFld.validationType = [.requiredField(errorMessage: " ")]
        dayTxtFld.continousValidation = true
        monthTxtFld.continousValidation = true
        yearTxtFld.continousValidation = true
        
        
        dayLbl.text = "DayTitle".localizedString
        monthLbl.text = "Month".localizedString
        yearLbl.text = "YearsTitle".localizedString
        
        
        nationalityLbl.text = "Nationality*".localizedString
        nationalityTxtFld.validationType = [.requiredField(errorMessage: "Select nationality".localizedString)]
        nationalityTxtFld.continousValidation = true
        nationalityTxtFld.placeholder = "Select nationality".localizedString
        
        
        let flds = [firstNameTxtFld,lastNameTxtFld,emailFld,dayTxtFld,monthTxtFld,yearTxtFld,nationalityTxtFld,genderTxtFld,promoTxtFld]
        for fld in flds {
            fld?.delegate = self
            fld?.addTarget(self, action: #selector(self.textFieldDidChange(sender:)), for: .editingChanged)
        }
        updateContinueButtonUI()
        if SmilesLanguageManager.shared.currentLanguage == .ar {
            backBtnView.transform = CGAffineTransformMakeScale(-1.0, 1.0)
        }
    }
    // MARK: -- Actions
    func moveToWelcome(){
        let vc = RegisterationSuccessViewController.get()
        vc.registrationCompleted = registrationCompleted
        vc.baseUrl = self.baseURL
        vc.mobileNumber = self.getAccountMobileNum()!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: -- Binding
    
    func bind(to viewModel: UserRegisterationViewModel) {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchInfoDidSucceed(let response):
                    let vc = ReferralPromoPopupViewController.get(data: response)
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalPresentationCapturesStatusBarAppearance = true
                    self?.present(vc)
                case .fetchDidFail(let error):
                    self?.showAlertWithOkayOnly(
                        message: error.localizedDescription,
                        title: "Error")
                    { _ in
                        
                    }
                case .registerUserDidFail(let error):
                    var errorDesc = error.localizedDescription
                    switch error{
                    case .apiError(_, let error):
                        errorDesc = error
                    default:break
                    }
                    self?.didFailRegistration(errorDesc)
                case .showHideLoader(let shouldShow):
                    if shouldShow {
                        SmilesLoader.show(isClearBackground: true)
                    } else {
                        SmilesLoader.dismiss()
                    }
                case .registerUserDidSucceed:
                    self?.didSucceedRegistration()
                    self?.moveToWelcome()
                case .verifyUserDetailsDidSucceed(let response):
                    self?.handleVerifyUserDetailsResponse(response: response)
                case .verifyingDetailsDidFail(let error):
                    self?.didGetErrorResponse(error.localizedDescription)
                }
            }
            .store(in: &cancellables)
    }
    public func handleVerifyUserDetailsResponse(response:VerifyUserDetailsResponse){
        SmilesLoader.dismiss()
        if let isVaild = response.isValid, isVaild == true{
            if let isVerified = response.isVerified, isVerified == true{
                self.enableTouchIdIfNotExist(self.getAccountMobileNum()!)
            }else{
                didFailExistingVerificationFailed(response.responseMsg.asStringOrEmpty(),response.responseDesc.asStringOrEmpty()){
                    self.enableTouchIdIfNotExist(self.getAccountMobileNum()!)
                }
            }
        }
        else{
            if let responseCode = response.responseCode, responseCode == "1"{
                //show pop up
                if let errorTitle = response.responseMsg, !errorTitle.isEmpty, let errorSubTitle = response.responseDesc,!errorSubTitle.isEmpty{
                    self.didShowPopUp(responseTitle: errorTitle, responseSubtitle: errorSubTitle)
                }
            }
            else{
                //show banner
                if let errorTitle = response.responseMsg, !errorTitle.isEmpty, let errorSubTitle = response.responseDesc,!errorSubTitle.isEmpty{
                    self.didShowBanner(responseTitle: errorTitle, responseSubtitle: errorSubTitle)
                }
            }
        }
    }
    public static func get(baseUrl:String) -> UserRegisterationViewController {
        let vc = UIStoryboard(name: "UserRegisteration", bundle: Bundle.module).instantiateViewController(withIdentifier: "UserRegisterationViewController") as! UserRegisterationViewController
        vc.baseURL = baseUrl
        return vc
    }
    
    func updateContinueButtonUI(){
        let isValid = isDataValid()
        continueBtn.backgroundColor = isValid ? UIColor(hex:"75428E") : UIColor(hex:"E9E9EC")
        let attributedString = NSMutableAttributedString(string:continueBtn.title(for: .normal) ?? "",  attributes: [
            .font: SmilesFonts.circular.getFont(style: .medium, size: 16),
            .foregroundColor: isValid ? .white : UIColor(hex:"A6A8B3")
        ])
        continueBtn.setAttributedTitle(attributedString, for: .normal)
    }
    func setupTermsUI(){
        let hint = SmilesLanguageManager.shared.getLocalizedString(for: "RegisterationTCWithContinue")
        let attributedString = NSMutableAttributedString(string:hint,  attributes: [
            .font: SmilesFonts.circular.getFont(style: .book, size: 14),
            .foregroundColor: UIColor(hex:"4D5167"),
            .kern: 0.0
        ])
        var range = NSRange(location:33, length: hint.count-33)
        if SmilesLanguageManager.shared.currentLanguage == .ar {
            range = NSRange(location:21, length: hint.count-21)
        }
        attributedString.addAttributes([.foregroundColor: UIColor.appRevampPurpleMainColor,
                                        .underlineStyle: NSUnderlineStyle.single.rawValue, .font: SmilesFonts.circular.getFont(style: .book, size: 14)], range: range)
        termsLbl.attributedText = attributedString
    }
    
    
    
    @IBAction func nationalityPressed(_ sender: Any) {
        
        if let vc = OnBoardingModuleManager.instantiateCountryCodeViewController() {
            
            let countriesResp = CountryListResponse()
            countriesResp.countryList = self.nationalities
            vc.countriesList = countriesResp
            
            vc.modalPresentationStyle = .overFullScreen
            vc.showCountryCodeInList = false
            vc.delegate = self
            
            present(vc, animated: true, completion: nil)
            
        }
    }
    
    @IBAction func genderPressed(_ sender: Any) {
        let options = ["MaleTitle".localizedString.capitalizingFirstLetter(),"FemaleTitle".localizedString.capitalizingFirstLetter(),"Prefer not to say".capitalizingFirstLetter().localizedString]
        let requestGenderOptions = ["M", "F", "P"]
        self.present(options:options){index in
            self.genderTxtFld.text = options[index]
            self.genderForRequest = requestGenderOptions[index]
            self.updateContinueButtonUI()
            if !self.promoCodeWrapper.isHidden {
                self.promoTxtFld.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func promoReferralInfoPressed(_ sender: Any) {
        self.input.send(.fetchInfo(type: .referralPromo))
    }
    
    @IBAction func termsPressed(_ sender: Any) {
        termsAndConditions()
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        if isDataValid(){
            let request = RegisterUserRequest()
            request.firstName = firstNameTxtFld.text?.removingWhitespaces()
            request.lastName = lastNameTxtFld.text?.removingWhitespaces()
            if !isExistingUser {
                request.email = emailFld.text
                request.gender = self.genderForRequest
                request.referralCode = promoTxtFld.text
            }
            request.birthDate = AppCommonMethods.convert(date: dob!, format: "dd-MM-yyyy")
            request.nationality = "\(self.nationality?.countryId ?? -1)"
            request.isExistingUser = isExistingUser
            self.input.send(!isExistingUser ? .registerUser(request: request) : .verifyUserDetails(request: request))
        }
    }
    func isDataValid() -> Bool {
        var isValid = true
        var fields = [firstNameTxtFld, lastNameTxtFld, dayTxtFld, monthTxtFld, yearTxtFld,nationalityTxtFld]
        if !isExistingUser{
            fields.append(contentsOf: [emailFld, genderTxtFld])
        }
        for field in fields {
            if !field!.validate() {
                isValid = false
            }
        }
        return isValid
    }
    @IBAction func dobPressed(_ sender: Any) {
        dayTxtFld.resignFirstResponder()
        monthTxtFld.resignFirstResponder()
        yearTxtFld.resignFirstResponder()
        presentDatePicker(selectedDate:self.dob ?? Date(), maxDate: Date()) { date in
            self.dob = date
            if !self.nationalityTxtFld.validate() {
                self.nationalityPressed(sender)
            }
            self.updateContinueButtonUI()
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
}
// MARK: - UITextFieldDelegate

extension UserRegisterationViewController : UITextFieldDelegate
{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text?.count ==  0 { return false }
        if textField == firstNameTxtFld
        {
            lastNameTxtFld.becomeFirstResponder()
        }
        else if textField == lastNameTxtFld {
            if !isExistingUser{
                emailFld.becomeFirstResponder()
            }
        }
        else if textField == emailFld {
            emailFld .resignFirstResponder()
        }
        else if textField == genderTxtFld {
            if isExistingUser {
                genderTxtFld .resignFirstResponder()
            }else {
                promoTxtFld.becomeFirstResponder()
            }
            
        }
        else if textField == promoTxtFld {
            promoTxtFld .resignFirstResponder()
        }
        return true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.containsEmoji { return false }
         return true
    }
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        let flds = [dayTxtFld,monthTxtFld,yearTxtFld,genderTxtFld]
        if flds.contains(where: {$0==textField}) {
            textField.resignFirstResponder()
        }
    }
    @objc func textFieldDidChange(sender:UITextField){
        updateContinueButtonUI()
    }
    
    //MARK: - Verify details for existing user
    
    func enableTouchIdIfNotExist(_ mobileNumber : String) {
        
        if !UserDefaults.standard.bool(forKey: "hasTouchId")
        {
            presentEnableTouchIdViewController()
        }
        else{
            if let mobileNumberForTouchId = UserDefaults.standard.string(forKey: "mobileNumberForTouchId"),!mobileNumberForTouchId.isEmpty
            {
                registrationCompleted()
            }
            else {
                presentEnableTouchIdViewController()
            }
        }
    }
    
    func presentEnableTouchIdViewController() {
        let moduleStoryboard = UIStoryboard(name: "EnableTouchIdStoryboard", bundle: .module)
        let vc = moduleStoryboard.instantiateViewController(identifier: "EnableTouchIdViewController", creator: { coder in
            EnableTouchIdViewController(coder: coder, baseURL: self.baseURL)
        })
        vc.mobileNumber = self.getAccountMobileNum() ?? ""
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(vc)
        
    }
    
    //MARK: - Show Banner and error Pop ups

    func showBanner(){

        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.constraint_bannerHeight.constant = 99
            self.lbl_bannerTitle.alpha = 1.0
            self.lbl_bannerSubTitle.alpha = 1.0
            self.view.layoutIfNeeded()
            self.perform(#selector(self.hideBanner), with:nil , afterDelay: 5.0)
        })
    }


    @objc func hideBanner(){
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            self.constraint_bannerHeight.constant = 0
            self.lbl_bannerTitle.alpha = 0.0
            self.lbl_bannerSubTitle.alpha = 0.0
            self.view.layoutIfNeeded()
        })
    }

    func updateBannerTexts(title : String = "", subTitle : String = ""){
        lbl_bannerTitle.text = title
        lbl_bannerSubTitle.text = subTitle
    }


    
    func getAccountMobileNum() -> String? {
        if let msisdn = UserDefaults.standard.string(forKey: "msisdn"), !msisdn.isEmpty {
            return msisdn
        }
        return ""
    }
    
    func didGetUserDetailsVerifiedAndHasNoVaildEmail(responseTitle: String, responseSubtitle: String, isEmailVerified: Bool) {
        
    }

    func didShowBanner(responseTitle: String, responseSubtitle: String) {

        updateBannerTexts(title:responseTitle, subTitle: responseSubtitle)
        showBanner()
    }

    func didShowPopUp(responseTitle: String, responseSubtitle: String) {
        didFailExistingVerificationFailed(responseTitle,responseSubtitle){}
    }

    func didGetErrorResponse(_ errorText: String) {
        updateBannerTexts(title:errorText)
        showBanner()
    }

}

// MARK: - Keyboard Handling
extension UserRegisterationViewController {
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDisappear(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func onKeyboardAppear(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            scrollView.contentInset = insets
            scrollView.scrollIndicatorInsets = insets
            
            var viewFrame = view.frame
            viewFrame.size.height -= keyboardHeight
            
            if let activeField = [firstNameTxtFld, lastNameTxtFld, emailFld, promoTxtFld].first(where: { $0.isFirstResponder }) {
                if !viewFrame.contains(activeField.frame.origin) {
                    let scrollPoint = CGPoint(x: 0, y: activeField.frame.origin.y - keyboardHeight)
                    scrollView.setContentOffset(scrollPoint, animated: true)
                }
            }
        }
    }


    @objc func onKeyboardDisappear(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    
}

extension UserRegisterationViewController: CountrySelectionDelegate {

    public func didSelectCountry(_ country: CountryList) {

        self.nationality = country

    }

}

extension UserRegisterationViewController: EnableTouchIdDelegate {
    public func didDismissEnableTouchVC() {
        self.registrationCompleted()
    }
}
