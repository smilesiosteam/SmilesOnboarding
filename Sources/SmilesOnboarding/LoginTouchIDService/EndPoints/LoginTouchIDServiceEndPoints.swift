//
//  LoginTouchIDServiceEndPoints.swift
//  House
//
//  Created by Ghullam  Abbas on 18/01/2024.
//  Copyright © 2024 Ahmed samir ali. All rights reserved.
//
import Foundation
import NetworkingLayer


public enum LoginTouchIDServiceEndPoints: String {
    case loginTouchID
}

extension LoginTouchIDServiceEndPoints {
    var serviceEndPoints: String {
        switch self {
        case .loginTouchID:
            return EndPoints.touchIddStatusEndpoint
        }
    }
}

