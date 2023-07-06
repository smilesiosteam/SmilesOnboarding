//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 06/07/2023.
//

import Foundation
import UIKit

public class UIDeviceHelper {
    
    public init() {
        
    }
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    public func isIphone() -> Bool {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return true
        }
        return false
    }

    public func isIphoneX() -> Bool {
        if  isIphone() && screenHeight >= 812.0 {
            return true
        }
        return false
    }
    
    var isSimulator: Bool {
        #if arch(i386) || arch(x86_64)
            return true
        #else
            return false
        #endif
    }
    
}
