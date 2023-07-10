//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 07/07/2023.
//

import LocalAuthentication
import SmilesLanguageManager

public enum BiometricType {
    case none
    case touchID
    case faceID
}

public class BiometricIDAuth {
    let context = LAContext()
    var loginReason = "Logging in with Touch ID"
    
    public init() {}
    
    public func biometricType() -> BiometricType {
        
        let _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        if #available(iOS 11.0, *) {
            switch context.biometryType {
            case .none:
                return .none
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
                
            default:
                return .none
            }
        }
        return .none
    }
    
    public func canEvaluatePolicy() -> Bool {
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    public func authenticateUser(completion: @escaping (String?) -> Void) {
        guard canEvaluatePolicy() else {
            completion("Touch ID not available")
            return
        }
        
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: loginReason) { (success, evaluateError) in
            if success {
                
                completion(nil)
                
            } else {
                //TODO: User did not authenticate successfully, look at error and take appropriate action
                //                guard let error = evaluateError else {
                //                    return
                //                }
                
                completion("error")
            }
        }
    }
    
    
    
    public func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start".localizedString
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue".localizedString
                
            case LAError.biometryNotEnrolled.rawValue:
                message = " user has not enrolled in biometric".localizedString
                
            default:
                message = "Did not find error code on LAError object".localizedString
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts".localizedString
                
            case LAError.touchIDNotAvailable.rawValue:
                message =  "TouchID is not available on the device".localizedString
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device".localizedString
                
            default:
                message = "Did not find error code on LAError object".localizedString
            }
        }
        
        return message;
    }
    
    public func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }
}
