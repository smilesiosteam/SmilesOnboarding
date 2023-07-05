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
    @IBOutlet weak var resendLabel: UILabel!
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
        descLbl2.text = otpHeaderText
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
                }
            }.store(in: &cancellables)
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController()
    }
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        self.input.send(.verifyOtp(otp: self.otpNumber))
    }
    
    func configureProfileStatus(response: GetProfileStatusResponse, msisdn: String, token: String) {
//            self.presenter.updateMainRequestWithData(msidsn: mobNumber, authToken: authenticationToken, loginType: .otp)
        if let status = response.profileStatus
        {
            SmilesBaseMainRequestManager.shared.baseMainRequestConfigs?.userInfo = nil
            LocationStateSaver.removeLocation()
            LocationStateSaver.removeRecentLocations()
//            self.presenter.saveUserLoginType(loginType: .otp)
            switch status {
            case 1 :
                //TODO: Enable Touch ID
//                enableTouchIdIfNotExist(mobNumber)
                return
            case 2 :
                //TODO: Navigate to Register User
//                navigateToRegistrationViewController()
                return
            case 3 :
                //TODO: Navigate to Existing User Flow
//                navigateToCheckExistingUserViewController()
                
                return
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
