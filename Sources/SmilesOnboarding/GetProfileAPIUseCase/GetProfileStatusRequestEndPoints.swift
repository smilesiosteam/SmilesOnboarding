//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 17/01/2024.
//

import Foundation
import NetworkingLayer


public enum GetProfileStatusRequestEndPoints: String {
    case getProfileStatus
}

extension GetProfileStatusRequestEndPoints {
    var serviceEndPoints: String {
        switch self {
        case .getProfileStatus:
            return EndPoints.getProfileStatusEndpoint
        }
    }
}
