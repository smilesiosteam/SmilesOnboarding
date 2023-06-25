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

@objc public class LoginWithOtpViewController: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var titleLbl: UILabel!
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
    @IBOutlet weak var mobileNumberFieldView: UIView! {
        didSet {
            mobileNumberFieldView.layer.cornerRadius = 12
            mobileNumberFieldView.layer.borderWidth = 1
            mobileNumberFieldView.layer.borderColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.2).cgColor
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
    var baseURL: String = ""
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
    }
    
    //MARK: Binding
    
    func bind(to viewModel: LoginWithOtpViewModel) {
        input = PassthroughSubject<LoginWithOtpViewModel.Input, Never>()
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchCountriesDidSucceed(response: let response):
                    print(response)
                case .fetchCountriesDidFail(error: let error):
                    debugPrint(error.localizedDescription)
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
}
