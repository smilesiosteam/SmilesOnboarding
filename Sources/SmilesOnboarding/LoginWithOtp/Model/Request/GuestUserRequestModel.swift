//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 05/07/2023.
//

import Foundation
import SmilesUtilities
import SmilesBaseMainRequestManager

class GuestUserRequestModel: SmilesBaseMainRequest {

    var operationName: String?

    
    init(operationName: String?) {
        super.init()
        self.operationName = operationName
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    
    enum CodingKeys: String, CodingKey {
        case operationName
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.operationName, forKey: .operationName)
    }
}
