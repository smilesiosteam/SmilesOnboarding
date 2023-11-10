//
//  File.swift
//
//
//  Created by Ahmed Naguib on 10/11/2023.
//

import Foundation
import DeviceAppCheck

protocol SecurityCheckerType {
    func check(mobileNumber: String, isInternationalNumber: Bool , completion: @escaping (SecurityChecker.State) -> Void)
}

final class SecurityChecker: SecurityCheckerType {
    func check(mobileNumber: String, isInternationalNumber: Bool , completion: @escaping (State) -> Void) {
      
        guard isInternationalNumber else {
            completion(.success(model: .init()))
            return
        }
        if OnBoardingModuleManager.isAppAttestEnabled {
            DeviceAppCheck.shared.getSecurityData { dcCheck, attestation, challenge, error  in
                if error != nil {
                    DispatchQueue.main.async {
                        completion(.showError(error: OnboardingLocalizationKeys.deviceJailBreakMsgText.text))
                    }
                } else {
                    var model = SecurityModel()
                    model.captcha = ""
                    model.deviceCheckToken = dcCheck
                    model.appAttestation = attestation
                    model.challenge = challenge
                    DispatchQueue.main.async {
                        completion(.success(model: model))
                    }
                    
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(.success(model: .init()))
            }
        }
    }
    
    
    private func internationalNumeber() {
        if OnBoardingModuleManager.isAppAttestEnabled {
            DeviceAppCheck.shared.getSecurityData { dcCheck, attestation, challenge, error  in
                if error != nil {
                    
                } else {
                    var model = SecurityModel()
                    model.captcha = ""
                    model.deviceCheckToken = dcCheck
                    model.appAttestation = attestation
                    model.challenge = challenge
                    
                }
            }
        }
    }
    
    private func isValidEmiratiNumber(phoneNumber: String) -> Bool {
        let phoneRegex = "^(?:\\+971|971)(?:2|3|4|6|7|9|50|51|52|54|55|56|58)[0-9]{7}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phoneNumber)
    }
}

extension SecurityChecker {
    enum State {
        case showError(error: String)
        case success(model: SecurityModel)
    }
}

extension SecurityChecker {
    struct SecurityModel {
        var captcha: String?
        var deviceCheckToken: String?
        var appAttestation: String?
        var challenge: String?
    }
}
