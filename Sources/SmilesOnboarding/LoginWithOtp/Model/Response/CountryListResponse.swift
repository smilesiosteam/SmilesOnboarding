//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 25/06/2023.
//

import Foundation
import NetworkingLayer
import SmilesUtilities

class CountryListResponse: BaseMainResponse {
    var countryList: [CountryList]? = []
    var lastModifiedDate: String? = ""
    
    enum CountryListResponseCodingKeys: String, CodingKey {
        case countryList
        case lastModifiedDate
    }
    
    override init() { super.init() }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CountryListResponseCodingKeys.self)

        countryList = try values.decodeIfPresent([CountryList].self, forKey: .countryList)
        lastModifiedDate = try values.decodeIfPresent(String.self, forKey: .lastModifiedDate)
        
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CountryListResponseCodingKeys.self)
        try container.encode(countryList, forKey: .countryList)
        try container.encode(lastModifiedDate, forKey: .lastModifiedDate)
        try super.encode(to: encoder)
    }
    
    public static func saveCountryListResponse(countries: CountryListResponse) {
        if let countryList = countries.countryList, countryList.count > 0 {
            let response = CountryListResponse()
            response.countryList = countryList.isEmpty ? [] : countryList
            response.lastModifiedDate = countries.lastModifiedDate.asStringOrEmpty()
            
            let fullEncoder = PropertyListEncoder()
            let fullData = try? fullEncoder.encode(response)
            UserDefaults.standard.set(fullData, forKey: "countryList")
        }
    }
    
    
    public static func getCountryListResponse() -> CountryListResponse? {
        if let countryResponseData = UserDefaults.standard.data(forKey: "countryList") {
            let fullDecoder = PropertyListDecoder()
            let countryResponse: CountryListResponse = try! fullDecoder.decode(CountryListResponse.self, from: countryResponseData)
            return countryResponse
        }
        return nil
    }
  
    
    public static func getCountryList() -> [CountryList]? {
        if let countryResponseData = UserDefaults.standard.data(forKey: "countryList") {
            let fullDecoder = PropertyListDecoder()
            let countryResponse: CountryListResponse = try! fullDecoder.decode(CountryListResponse.self, from: countryResponseData)
            if let countryList = countryResponse.countryList, countryList.count > 0 {
                return countryList
            }
        }
        return nil
    }
    
    
    public static func getLastModifiedDate() -> String {
        if let countryResponseData = UserDefaults.standard.data(forKey: "countryList") {
            let fullDecoder = PropertyListDecoder()
            let countryResponse: CountryListResponse = try! fullDecoder.decode(CountryListResponse.self, from: countryResponseData)
            return countryResponse.lastModifiedDate.asStringOrEmpty()
        }
        return .emptyString
    }
    
    
    public static func isCountriesListAvailableInCache() -> Bool {
        if let countryListResponse = CountryListResponse.getCountryList(), countryListResponse.count > 0 {
            return true
        }
        return false
    }
    
    
    func asDictionary() -> [String: Any] {
        let encoder = DictionaryEncoder()
        guard let encoded = try? encoder.encode(self) as [String: Any] else {
            return [:]
        }
        return encoded
    }
}
