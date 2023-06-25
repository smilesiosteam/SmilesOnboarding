//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 25/06/2023.
//

import Foundation
import SmilesUtilities

class CountryListRequest : Codable   {
    
    var firstCallFlag : Bool?
    var lastModifiedDate : String?
    
    enum CountryListResponseCodingKeys: String, CodingKey {
        case countryList = "firstCallFlag"
        case lastModifiedDate = "lastModifiedDate"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        firstCallFlag = try values.decodeIfPresent(Bool.self, forKey: .firstCallFlag)
        lastModifiedDate = try values.decodeIfPresent(String.self, forKey: .lastModifiedDate)
    }
    
    init() {
        self.firstCallFlag = true
        self.lastModifiedDate = ""
    }
    
    
    func asDictionary(dictionary :[String : Any]) -> [String : Any] {
        
        let encoder = DictionaryEncoder()
        guard  let encoded = try? encoder.encode(self) as [String:Any]  else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary:dictionary)
        
    }
    
}
