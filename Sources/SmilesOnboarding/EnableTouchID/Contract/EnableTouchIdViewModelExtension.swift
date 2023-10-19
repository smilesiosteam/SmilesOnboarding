//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 07/07/2023.
//

import Foundation
import Combine
import NetworkingLayer

extension EnableTouchIdViewModel {
    enum Input {
        case authenticateTouchId(token: String, isEnabled: Bool)
    }
    
    enum Output {
        case authenticateTouchIdDidSucceed(response: EnableTouchIdResponseModel)
        case authenticateTouchIdDidfail(error: NetworkError)
    }
}
