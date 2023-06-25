//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 25/06/2023.
//

import Foundation

extension LoginWithOtpViewModel {
    enum Input {
        case getCountriesList(lastModifiedDate: String ,firstCall: Bool)
    }
    
    enum Output {
        case fetchCountriesDidSucceed(response: CountryListResponse)
        case fetchCountriesDidFail(error: Error)
    }
}
