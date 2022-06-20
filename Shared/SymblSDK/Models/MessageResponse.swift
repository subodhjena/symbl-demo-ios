//
//  MessageResponse.swift
//  SymblDemo (iOS)
//
//  Created by Subodh Jena on 20/06/22.
//

import Foundation

// MARK: - MessageResponse
struct SymblMessageResponse: Codable {
    let type: String
    let messages: [MessageResponseClass]
    let sequenceNumber: Int
}

// MARK: - Message
struct MessageResponseClass: Codable {
    let from: From
    let payload: PayloadMessageResponseClass
    let id: String
    let channel: Channel
    let metadata: Metadata
    let dismissed: Bool
    let duration: Duration
}

// MARK: - Channel
struct Channel: Codable {
    let id: String
}

// MARK: - Duration
struct Duration: Codable {
    let startTime, endTime: String
}

// MARK: - From
struct From: Codable {
    let id, name, userID: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case userID = "userId"
    }
}

// MARK: - Metadata
struct Metadata: Codable {
    let disablePunctuation: Bool
    let originalContent, words, originalMessageID: String
    let timezoneOffset: Int?

    enum CodingKeys: String, CodingKey {
        case disablePunctuation, originalContent, words
        case originalMessageID = "originalMessageId"
        case timezoneOffset
    }
}

// MARK: - Payload
struct PayloadMessageResponseClass: Codable {
    let content, contentType: String
}
