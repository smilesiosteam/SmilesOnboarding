//
//  RegisterUserResponse.swift
//  
//
//  Created by Shmeel Ahmed on 26/06/2023.
//

import Foundation

import Foundation
import NetworkingLayer
import SmilesUtilities

public class RegisterUserResponse : BaseMainResponse {
    
    
    public var bonusAmount : String? = nil
    public var bonusImage : String? = nil
    public var button : String? = nil
    public var expiryDate : String? = nil
    public var footerText : String? = nil
    public var gift : String? = nil
    public var description : String? = nil
    public var imageURL : String? = nil
    public var isValidEmail : Bool?
    public var promoFlag : Bool?
    public var referralCode : String? = nil
    public var subTitle : String? = nil
    public var title : String? = nil
    public var topImage : String? = nil
    public var type : Int?
    public var termsAndCondition : String? = nil
    public var offerId : String? = nil

    enum RegisterUserResponseCodingKeys: String, CodingKey {
        case bonusAmount = "bonusAmount"
        case bonusImage = "bonusImage"
        case button = "button"
        case expiryDate = "expiryDate"
        case footerText = "footerText"
        case gift = "gift"
        case description = "description"
        case imageURL = "imageURL"
        case isValidEmail = "isValidEmail"
        case promoFlag = "promoFlag"
        case referralCode = "referralCode"
        case subTitle = "subTitle"
        case title = "title"
        case topImage = "topImage"
        case type = "type"
        case offerId = "offerId"
        case termsAndCondition = "termsAndCondition"
    }
    
    
    public static func saveRegisterUserResponse(enrollData :RegisterUserResponse){
        
        let fullEncoder = PropertyListEncoder()
        let fullData = try! fullEncoder.encode(enrollData)
        UserDefaults.standard.set(fullData, forKey: "enrollData")
        UserDefaults.standard.synchronize()
    }
    
    public static  func getRegisterUserResponse() -> RegisterUserResponse?{
        if let enrollData = UserDefaults.standard.data(forKey: "enrollData"){
            let fullDecoder = PropertyListDecoder()
            let RegisterUserResponse: RegisterUserResponse = try! fullDecoder.decode(RegisterUserResponse.self, from: enrollData)
            return RegisterUserResponse
        }
        return nil
    }
    
    public  static func removeEnrollReponse(){
        UserDefaults.standard.removeObject(forKey: "enrollData")
    }
}
