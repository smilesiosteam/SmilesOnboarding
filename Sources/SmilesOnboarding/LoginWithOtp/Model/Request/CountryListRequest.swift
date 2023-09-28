//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 25/06/2023.
//

import Foundation
import SmilesUtilities

public class CountryListRequest : Codable   {
    
    public var firstCallFlag : Bool?
    public var lastModifiedDate : String?
    
    public enum CountryListResponseCodingKeys: String, CodingKey {
        case countryList = "firstCallFlag"
        case lastModifiedDate = "lastModifiedDate"
    }
    
    required public init(from decoder: Decoder) throws {
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            firstCallFlag = try values.decodeIfPresent(Bool.self, forKey: .firstCallFlag)
            lastModifiedDate = try values.decodeIfPresent(String.self, forKey: .lastModifiedDate)
        } catch {
            print("Error initializing CountryListRequest: \(error)")
        }
    }
    
    public init() {
        self.firstCallFlag = true
        self.lastModifiedDate = ""
    }
    
    
    public func asDictionary(dictionary :[String : Any]) -> [String : Any] {
        
        let encoder = DictionaryEncoder()
        guard  let encoded = try? encoder.encode(self) as [String:Any]  else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary:dictionary)
        
    }
    
}
