//
//  RegisterationSuccessViewController.swift
//  House
//
//  Created by Shmeel Ahmad on 1/24/19.
//  Copyright © 2019 Ahmed samir ali. All rights reserved.
//

import UIKit
import LottieAnimationManager

class RegisterationSuccessViewController: UIViewController {
    
    @IBOutlet weak var btn_langauge: UIButton!
    
    @IBOutlet weak var img_smilesLogo: UIImageView!
    
    @IBOutlet weak var successImage: UIImageView!
    @IBOutlet weak var btn_done: UIButton!
    var mobileNumber : String!
        
    var registrationCompleted = {}
    override func viewDidLoad() {
        super.viewDidLoad()
        LottieAnimationManager.showAnimation(onView: successImage, withJsonFileName: "Thank you for sending your feedback 198x169", removeFromSuper: false, loopMode: .loop) {(bool) in
            
        }
//        self.presenter.applyLanguageChange(view: self.view, button: btn_done)
        // Do any additional setup after loading the view.
    }
    
    public override  func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)
//            UIApplication.delegte().currentPresentedViewController = self

        }
    
    static func get() -> RegisterationSuccessViewController {
        return UIStoryboard(name: "RegisterationSuccess", bundle: Bundle.module).instantiateViewController(withIdentifier: "RegisterationSuccessViewController") as! RegisterationSuccessViewController
    }
    
    @IBAction func didSelectLanguageButtonAction(_ sender: Any) {
//        if LanguageManager.sharedInstance()?.currentLanguage == English {
//
//            LanguageManager.sharedInstance()?.switchLanguageToArabic()
//
//            btn_langauge.setTitle(LanguageManager.sharedInstance()?.getLocalizedString(forKey: "EnglishTitle"), for: .normal)
//
//        }
//        else {
//
//            LanguageManager.sharedInstance()?.switchLanguageToEnglish()
//
//            btn_langauge.setTitle(LanguageManager.sharedInstance()?.getLocalizedString(forKey: "arabicTitle"), for: .normal)
//
//        }
//        self.presenter.reloadViewControllerAfterChangeLanguage()
//        img_smilesLogo.image = self.presenter.showSmilesLogoBasedOnLanguage()
//
//        self.presenter.applyLanguageChange(view: self.view, button: btn_done)
        
    }
    
    
    @IBAction func didSelectDoneButtonAction(_ sender: Any) {
        registrationCompleted()
//        if !self.presenter.checkIfTouchIdEnabled(){
//            if self.presenter.checkIfDeviceSupportToucId(){
//                openEnableTouchIdViewController()
//            }
//            else{
//                navigateToHomeScreen()
//            }
//        }
//        else{
//            navigateToHomeScreen()
//        }
        
    }
    
    func openEnableTouchIdViewController()  {
        
        self.performSegue(withIdentifier: "TouchIdModel", sender: nil)
        
    }
    
    
    
    // MARK: - Navigation
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        if segue.identifier == "TouchIdModel" {
//            let enableTouchIdViewControlelr = segue.destination as! EnableTouchIdViewController
//            enableTouchIdViewControlelr.delegate = self
//            enableTouchIdViewControlelr.mobileNumber = self.presenter.getAccountMobileNum()!
//        }
    }
    func showDoneButtonTitle(button : UIButton) {
//        button.setTitle(LanguageManager.sharedInstance()?.getLocalizedString(forKey: button.accessibilityHint), for: .normal)
    }
    
    func applyLanguageChange(view : UIView, button : UIButton)  {
        
//        CommonMethods.applyLocalizedStrings(toAllViews:view)
        
        showDoneButtonTitle(button: button)
        
    }
    
}
