//
//  FetchInfoRequest.swift
//  
//
//  Created by Shmeel Ahmed on 26/06/2023.
//

import Foundation
import SmilesBaseMainRequestManager


class FetchInfoRequest: SmilesBaseMainRequest {

    // MARK: - Model Variables
    var infoType: String = ""
    init(infoType: String) {
        super.init()
        self.infoType = infoType
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    // MARK: - Model Keys
    enum CodingKeys: CodingKey {
        case infoType
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.infoType, forKey: .infoType)
    }
}
public enum InfoType:String {
    case referralPromo = "REFERRAL_AND_PROMO"
}
