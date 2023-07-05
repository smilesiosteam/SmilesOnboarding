//
//  InfoResponse.swift
//  
//
//  Created by Shmeel Ahmed on 26/06/2023.
//

import Foundation

// MARK: - InfoResponse
public class InfoResponse: Codable {
    let extTransactionID: String
    let info: Info

    enum CodingKeys: String, CodingKey {
        case extTransactionID = "extTransactionId"
        case info
    }

    init(extTransactionID: String, info: Info) {
        self.extTransactionID = extTransactionID
        self.info = info
    }
}

// MARK: - Info
public class Info: Codable {
    let title, description: String
    let items: [Item]

    init(title: String, description: String, items: [Item]) {
        self.title = title
        self.description = description
        self.items = items
    }
}

// MARK: - Item
public class Item: Codable {
    let title, description: String
    let iconURL: String

    enum CodingKeys: String, CodingKey {
        case title, description
        case iconURL = "iconUrl"
    }

    init(title: String, description: String, iconURL: String) {
        self.title = title
        self.description = description
        self.iconURL = iconURL
    }
}
