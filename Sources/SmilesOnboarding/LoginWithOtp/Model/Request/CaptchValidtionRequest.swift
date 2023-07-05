//
//  File.swift
//  
//
//  Created by Shahroze Zaheer on 03/07/2023.
//

import Foundation
import SmilesUtilities

class CaptchValidtionRequest: Codable {
    var channel: String?
    var msisdn: String?
    var deviceId: String?
    var reGenerate: Bool?
    
    enum CodingKeys: String, CodingKey {
        case channel
        case msisdn
        case deviceId
        case reGenerate
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        channel = try values.decodeIfPresent(String.self, forKey: .channel)
        msisdn = try values.decodeIfPresent(String.self, forKey: .msisdn)
        deviceId = try values.decodeIfPresent(String.self, forKey: .deviceId)
        reGenerate = try values.decodeIfPresent(Bool.self, forKey: .reGenerate)
    }

    init() {}

    func asDictionary(dictionary: [String: Any]) -> [String: Any] {
        let encoder = DictionaryEncoder()
        guard let encoded = try? encoder.encode(self) as [String: Any] else {
            return [:]
        }
        return encoded.mergeDictionaries(dictionary: dictionary)
    }
}
