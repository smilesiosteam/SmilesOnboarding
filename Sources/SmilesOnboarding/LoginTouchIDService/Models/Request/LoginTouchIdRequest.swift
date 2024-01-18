//
//  LoginTouchIdRequest.swift
//  House
//
//  Created by Ghullam  Abbas on 18/01/2024.
//  Copyright © 2024 Ahmed samir ali. All rights reserved.
//

import Foundation
import SmilesUtilities
import SmilesBaseMainRequestManager

public class LoginTouchIdRequest : SmilesBaseMainRequest {
    
    var touchIdToken : String?
    
    enum CodingKeys: String, CodingKey {
        case touchIdToken = "touchIdToken"
    }
    init(touchIdToken: String? = "") {
        self.touchIdToken = touchIdToken
        super.init()
    }
    
    required  init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        touchIdToken = try values.decodeIfPresent(String.self, forKey: .touchIdToken)
        try super.init(from: decoder)
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.touchIdToken, forKey: .touchIdToken)
    }
    func asDictionary(dictionary :[String : Any]) -> [String : Any] {
        
        let encoder = DictionaryEncoder()
        guard  let encoded = try? encoder.encode(self) as [String:Any]  else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary:dictionary)
        
    }
}
