//
//  EnableTouchIdRequestModel.swift
//  House
//
//  Created by Shahroze Zaheer on 07/07/2023.
//  Copyright (c) 2023 All rights reserved.
//


import Foundation
import SmilesBaseMainRequestManager

class EnableTouchIdRequestModel: SmilesBaseMainRequest {
    
    var enabled : Bool?
    var touchIdToken : String?
    
    
    init(enabled: Bool?, touchIdToken: String?) {
        super.init()
        self.enabled = enabled
        self.touchIdToken = touchIdToken
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    
    enum CodingKeys: String, CodingKey {
        case enabled
        case touchIdToken
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.enabled, forKey: .enabled)
        try container.encodeIfPresent(self.touchIdToken, forKey: .touchIdToken)
    }
}


    
