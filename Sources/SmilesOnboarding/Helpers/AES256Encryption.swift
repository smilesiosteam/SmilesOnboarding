//
//  File.swift
//  
//
//  Created by Ahmed Naguib on 19/10/2023.
//

import Foundation
import SmilesBaseMainRequestManager

struct AES256Encryption {
    
    static func encrypt(with key: String) -> String {
        let aes256 = AESEncryption(key: EncryptionData.encryptionkey.rawValue, iv: EncryptionData.initVector.rawValue)
        guard let encryptedKey = aes256?.encryptDataWithNewHash(stringToHash: key) else {
            return ""
        }
        return encryptedKey
    }
}


fileprivate enum EncryptionData: String {
     case encryptionkey = "BDFHJLNPpnljhfdb"
     case initVector = "MDJ47Yyu9PPwBASx"
}
