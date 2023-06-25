//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 26/06/2023.
//

import Foundation

public enum SmilesOnboardingEndPoints: String, CaseIterable {
    case getCountries
}

extension SmilesOnboardingEndPoints {
    var serviceEndPoints: String {
        switch self {
        case .getCountries:
            return "home/get-country-list-v2"
        }
    }
}
