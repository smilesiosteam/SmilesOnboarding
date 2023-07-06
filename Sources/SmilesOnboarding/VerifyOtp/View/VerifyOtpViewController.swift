//
//  VerifyOtpViewController.swift
//  
//
//  Created by Shahroze Zaheer on 04/07/2023.
//

import UIKit
import DPOTPView
import Combine
import SmilesBaseMainRequestManager
import SmilesLocationHandler
import SmilesLanguageManager
import SmilesLoader

public class VerifyOtpViewController: UIViewController {
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
    @IBOutlet weak var backBtnView: UIView! {
        didSet {
            backBtnView.layer.cornerRadius = 16
        }
    }
    @IBOutlet weak var otpView: DPOTPView! {
        didSet {
            otpView.dpOTPViewDelegate = self
            otpView.fontTextField = UIFont.circularXXTTBookFont(size: 24)
            otpView.dismissOnLastEntry = true
        }
    }
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var resendBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton! {
        didSet {
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
    var countdownTimer: Timer?
    var timeRemaining = 0 {
        didSet {
            updateTimerLabel()
        }
    }
    
    //MARK: CallBacks
    public var navigateToRegisterViewCallBack: ((String, String, LoginType, Bool) -> Void)?
    
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
        enableLoginButton(isEnable: false)
        if let otptext = otpHeaderText {
            descLbl2.text = otptext
        } else {
            descLbl2.text = getVerifyOtpHint(mobileNumber: mobileNumber.asStringOrEmpty())
        }
        setupResendButton()
        startTimer()
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
                    }
                case .verifyOtpDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                case .getProfileStatusDidSucceed(response: let response, msisdn: let msisdn, authToken: let authToken):
                    self?.configureProfileStatus(response: response, msisdn: msisdn, token: authToken)
                case .getProfileStatusDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                case .showLoader(shouldShow: let shouldShow):
                    shouldShow ? SmilesLoader.show(isClearBackground: true) : SmilesLoader.dismiss()
                case .getOTPforMobileNumberDidSucceed(response: let response):
                    if let time = response.timeout {
                        self?.otpTimeOut = time
                        self?.resendBtn.isHidden = true
                        self?.enableLoginButton(isEnable: false)
                        self?.startTimer()
                    }
                    
                case .getOTPforMobileNumberDidFail(error: let error):
                    debugPrint(error.localizedDescription)
                }
            }.store(in: &cancellables)
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController()
    }
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        self.input.send(.verifyOtp(otp: self.otpNumber))
    }
    
    @IBAction func resendBtnTapped(_ sender: Any) {
        self.input.send(.getOTPforMobileNumber(mobileNumber: self.mobileNumber.asStringOrEmpty()))
    }
    func configureProfileStatus(response: GetProfileStatusResponse, msisdn: String, token: String) {
//            self.presenter.updateMainRequestWithData(msidsn: mobNumber, authToken: authenticationToken, loginType: .otp)
        if let status = response.profileStatus
        {
            SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.userInfo = nil
            LocationStateSaver.removeLocation()
            LocationStateSaver.removeRecentLocations()

            switch status {
            case 1 :
                //TODO: Enable Touch ID
//                enableTouchIdIfNotExist(mobNumber)
                return
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
    
    func getVerifyOtpHint( mobileNumber : String) -> String {
        let text = "OtpHint".localizedString
        
        if mobileNumber.count > 10 , mobileNumber.count < 15
        {
            var hintText = text
            var nubmer = mobileNumber
            nubmer.replacingCharacter(value: mobileNumber, startIndexOffsetBy:6, endIndexOffsetBy: 11, replaceWith: "*****")
            if SmilesLanguageManager.shared.currentLanguage == .en {
                hintText += nubmer
            } else {
                hintText += "\n" + nubmer
            }
            return hintText
            
        }
        return text
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
}

extension VerifyOtpViewController: DPOTPViewDelegate {
    public func dpOTPViewAddText(_ text: String, at position: Int) {
        print("addText:- " + text + " at:- \(position)" )
        if text.count == 6 {
            self.enableLoginButton(isEnable: true)
        } else {
            self.enableLoginButton(isEnable: false)
        }
        self.otpNumber = text
    }
    
    public func dpOTPViewRemoveText(_ text: String, at position: Int) {
        print("removeText:- " + text + " at:- \(position)" )
        if text.count == 6 {
            self.enableLoginButton(isEnable: true)
        } else {
            self.enableLoginButton(isEnable: false)
        }
        self.otpNumber = text
    }
    
    public func dpOTPViewChangePositionAt(_ position: Int) {
        print("at:-\(position)")
    }
    
    public func dpOTPViewBecomeFirstResponder() {
    }
    
    public func dpOTPViewResignFirstResponder() {
        
    }
}
