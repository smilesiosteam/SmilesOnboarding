//
//  RegisterationSuccessViewController.swift
//  House
//
//  Created by Shmeel Ahmad on 1/24/19.
//  Copyright © 2019 Ahmed samir ali. All rights reserved.
//

import UIKit
import LottieAnimationManager
import SmilesUtilities

class RegisterationSuccessViewController: UIViewController {
    @IBOutlet weak var img_smilesLogo: UIImageView!
    
    @IBOutlet weak var successImage: UIImageView!
    @IBOutlet weak var btn_done: UIButton!
    var mobileNumber: String?
    var baseUrl: String?
    
    @IBOutlet weak var congratulationsLbl: UILabel!
    
    @IBOutlet weak var subtitleLbl: UILabel!
    
    @IBOutlet weak var infoLbl: UILabel!
    
    
    
    var registrationCompleted = {}
    override func viewDidLoad() {
        super.viewDidLoad()
        LottieAnimationManager.showAnimation(onView: successImage, withJsonFileName: "Thank you for sending your feedback 198x169", removeFromSuper: false, loopMode: .loop) {(bool) in }
        
        btn_done.setTitle("DoneTitle".localizedString, for: .normal)
        congratulationsLbl.text = "ShareCongratulationsTitle".localizedString
        subtitleLbl.text = "you are all set to start enjoying Smiles!".localizedString
        infoLbl.text = "We have sent you a welcome email with a link to verify your Email address. Link expires in 24 hours.".localizedString
    }
    
    public override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    static func get() -> RegisterationSuccessViewController {
        UIStoryboard(name: "RegisterationSuccess", bundle: Bundle.module).instantiateViewController(withIdentifier: "RegisterationSuccessViewController") as! RegisterationSuccessViewController
    }
    
    
    @IBAction func didSelectDoneButtonAction(_ sender: Any) {
        if !UserDefaults.standard.bool(forKey: "hasTouchId") {
            presentEnableTouchIdViewController()
        }
        else{
            registrationCompleted()
        }
    }
    
    func presentEnableTouchIdViewController() {
        let moduleStoryboard = UIStoryboard(name: "EnableTouchIdStoryboard", bundle: .module)
        let vc = moduleStoryboard.instantiateViewController(identifier: "EnableTouchIdViewController", creator: { coder in
            EnableTouchIdViewController(coder: coder, baseURL: self.baseUrl ?? "")
        })
        vc.mobileNumber = self.mobileNumber ?? ""
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(vc)
    }
}

extension RegisterationSuccessViewController: EnableTouchIdDelegate {
    public func didDismissEnableTouchVC(_ viewController: UIViewController) {
        viewController.dismiss(animated: true)
        self.registrationCompleted()
    }
}
