//
//  EnableTouchIdViewController.swift
//  House
//
//  Created by Shahroze Zaheer on 07/07/2023.
//  Copyright (c) 2023 All rights reserved.
//

import UIKit
import Combine

public protocol EnableTouchIdDelegate: AnyObject {
    func didDismissEnableTouchVC(_ viewController: UIViewController)
}

public class EnableTouchIdViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var touchIDImg: UIImageView!
    @IBOutlet weak var enableTouchId: UIButton!
    @IBOutlet weak var enableTouchIdTitle: UILabel!
    @IBOutlet weak var maybeBtn: UIButton!
    
    
    
    // MARK: -- Variables
    private let input: PassthroughSubject<EnableTouchIdViewModel.Input, Never> = .init()
    private var baseURL: String = ""
    private var cancellables = Set<AnyCancellable>()
    private let touchMe = BiometricIDAuth()
    private var viewModel: EnableTouchIdViewModel!
    
    public weak var delegate: EnableTouchIdDelegate?
    public var mobileNumber: String = ""
    
    public init?(coder: NSCoder, baseURL: String) {
        super.init(coder: coder)
        self.baseURL = baseURL
        viewModel = EnableTouchIdViewModel(baseURL: baseURL)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: -- View LifeCycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(to: viewModel)
    }
        
    // MARK: -- Binding
    
    func bind(to viewModel: EnableTouchIdViewModel) {
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .authenticateTouchIdDidSucceed(let response):
                    if let status = response.status, status = 204 {
                        
                    }
                case .authenticateTouchIdDidfail(let error):
                    debugPrint(error.localizedDescription)
                }
            }.store(in: &cancellables)
    }
    
    @IBAction func enableBtntapped(_ sender: Any) {
        touchMe.authenticateUser { (error) in
            if let errorText = error, !errorText.isEmpty{
                self.showAlertWithOkayOnly(message: error ?? "", title: "")
            }
            else {
                // Success
                self.saveMobileNumberInKeychain(self.mobileNumber)
                guard let token = self.generateTouchIdToken(MobileNum: self.mobileNumber) else {return}
                self.input.send(.authenticateTouchId(token: token, isEnabled: true))
            }
        }
    }
    
    @IBAction func maybeBtntapped(_ sender: Any) {
        delegate?.didDismissEnableTouchVC(self)
    }
    
    func setupUI() {
        self.touchIDImg.image = UIImage(named: showTouchIdImage())
        self.enableTouchIdTitle.text = showTouchIdText()
        
    }
    
    func saveMobileNumberInKeychain(_ mobileNumber: String) {
        let status = KeyChain.save(key: "MyNumber", data: Data(from: Int(mobileNumber)))
        print(status)
    }
    
    func generateTouchIdToken(MobileNum: String) -> String? {
        let vendorId = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let finalToken = vendorId + MobileNum
        return finalToken.md5()
    }
}

extension EnableTouchIdViewController {
    func showTouchIdImage() -> String
    {
        return  UIDeviceHelper().isIphoneX() ? "face_id_consumer" : "TouchID"
    }
    
    func showTouchIdText() -> String
    {
        return  UIDeviceHelper().isIphoneX() ? "Activate your Face Id for quicker access".localizedString : "Activate your Touch ID for quicker access".localizedString
    }
}
