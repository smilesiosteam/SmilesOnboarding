//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 25/06/2023.
//

import Foundation
import SmilesLanguageManager
import SmilesUtilities

public class CountryList : Codable {
    
    
    public let countryId : Int?
    public let countryNameEn : String?
    public let flagIconUrl : String?
    public let iddCode : String?
    public let countryNameAR : String?
    public var countryName : String!
    
   public enum CodingKeys: String, CodingKey {
        case countryId = "countryId"
        case countryName = "countryName"
        case flagIconUrl = "flagIconUrl"
        case iddCode = "iddCode"
        case countryNameAR = "countryNameAR"
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        countryId = try values.decodeIfPresent(Int.self, forKey: .countryId)
        flagIconUrl = try values.decodeIfPresent(String.self, forKey: .flagIconUrl)
        iddCode = try values.decodeIfPresent(String.self, forKey: .iddCode)
        countryNameEn = try values.decodeIfPresent(String.self, forKey: .countryName)
        countryNameAR = try values.decodeIfPresent(String.self, forKey: .countryNameAR)
        
        if SmilesLanguageManager.shared.currentLanguage == .en {
            countryName = try values.decodeIfPresent(String.self, forKey: .countryName)
        }
        else{
            countryName =  try values.decodeIfPresent(String.self, forKey: .countryNameAR)
        }
    }
    
    
    public func getCountryName() -> String?{
        
        if SmilesLanguageManager.shared.currentLanguage == .en {
            return self.countryNameEn.asStringOrEmpty()
        }
        else{
            return self.countryNameAR.asStringOrEmpty()
        }
    }
    
}
