//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 03/07/2023.
//

import Foundation
import SmilesUtilities
import SmilesBaseMainRequestManager

public class CaptchValidtionRequest: SmilesBaseMainRequest {
    
    var reGenerate: Bool?
    
    init(reGenerate: Bool?) {
        super.init()
        self.reGenerate = reGenerate
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    enum CodingKeys: String, CodingKey {
        case reGenerate
    }
    
    public override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.reGenerate, forKey: .reGenerate)
    }
    
}

